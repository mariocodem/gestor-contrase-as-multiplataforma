import { Hono } from "hono";
import { createMiddleware } from "hono/factory";
import type { AppEnv, Bindings, SessionUser } from "./env";
import { sendResetEmail } from "./mail";
import { resetPage } from "./reset-page";
import {
  ApiError,
  constantTimeEqual,
  DAY,
  fromBase64,
  HOUR,
  MINUTE,
  normalizeEmail,
  randomToken,
  readJson,
  sha256,
  sha256Hex,
  splitList,
  toBase64,
} from "./support";

/**
 * Accounts decide *whose* ciphertext can be read; they never see the master password, nor even the
 * account password: the device derives a 256-bit auth key from it (PBKDF2, 600 000 iterations) and
 * only that key travels. Heavy hashing on the device also keeps every request here well inside the
 * Workers CPU limit.
 */
const AUTH_KEY_BYTES = 32;
const SESSION_TTL = 60 * DAY;
const RESET_TTL = HOUR;

const LOGIN_WINDOW = 15 * MINUTE;
const LOGIN_LIMIT_PER_EMAIL = 10;
const LOGIN_LIMIT_PER_ADDRESS = 30;
const RESET_WINDOW = HOUR;
const RESET_LIMIT_PER_EMAIL = 3;

export const auth = new Hono<AppEnv>();

auth.post("/v1/register", async (c) => {
  const body = await readJson(c.req.raw);
  const email = normalizeEmail(body.email);
  if (!email) throw new ApiError(400, "invalid_email");
  const authKey = parseAuthKey(body.authKey);

  const allowed = splitList(c.env.ALLOWED_EMAILS).map((item) => item.toLowerCase());
  if (allowed.length > 0 && !allowed.includes(email)) throw new ApiError(403, "registration_closed");

  const id = crypto.randomUUID();
  const created = await c.env.DB.prepare(
    "INSERT INTO users (id, email, auth_hash, created_at) VALUES (?, ?, ?, ?) ON CONFLICT (email) DO NOTHING RETURNING id",
  )
    .bind(id, email, await hashAuthKey(authKey), Date.now())
    .first<{ id: string }>();
  if (!created) throw new ApiError(409, "email_in_use");

  return c.json({ token: await openSession(c.env, id), user: { id, email } }, 201);
});

auth.post("/v1/login", async (c) => {
  const body = await readJson(c.req.raw);
  const email = normalizeEmail(body.email);
  if (!email) throw new ApiError(400, "invalid_email");
  const authKey = parseAuthKey(body.authKey);

  const limits: Limit[] = [
    { key: `login:email:${email}`, max: LOGIN_LIMIT_PER_EMAIL },
    { key: `login:ip:${clientAddress(c.req.raw)}`, max: LOGIN_LIMIT_PER_ADDRESS },
  ];
  if (await isLimited(c.env.DB, limits, LOGIN_WINDOW)) throw new ApiError(429, "too_many_requests");

  const user = await c.env.DB.prepare("SELECT id, email, auth_hash FROM users WHERE email = ?")
    .bind(email)
    .first<{ id: string; email: string; auth_hash: string }>();
  // Hash even for an unknown email, so the response time doesn't tell which accounts exist.
  const valid = await verifyAuthKey(authKey, user?.auth_hash ?? DUMMY_HASH);
  if (!user || !valid) {
    await recordAttempt(c.env.DB, limits, LOGIN_WINDOW);
    throw new ApiError(401, "invalid_credentials");
  }
  await c.env.DB.prepare("DELETE FROM login_failures WHERE key = ?").bind(limits[0].key).run();

  return c.json({ token: await openSession(c.env, user.id), user: { id: user.id, email: user.email } });
});

/** Resolves the bearer token to its user, sliding the session forward at most once a day. */
export const requireUser = createMiddleware<AppEnv>(async (c, next) => {
  const header = c.req.header("Authorization") ?? "";
  const token = header.startsWith("Bearer ") ? header.slice(7).trim() : "";
  if (!token) throw new ApiError(401, "unauthorized");

  const tokenHash = await sha256Hex(token);
  const now = Date.now();
  const session = await c.env.DB.prepare(
    "SELECT u.id, u.email, s.expires_at FROM sessions s JOIN users u ON u.id = s.user_id WHERE s.token_hash = ?",
  )
    .bind(tokenHash)
    .first<SessionUser & { expires_at: number }>();
  if (!session || session.expires_at <= now) throw new ApiError(401, "unauthorized");

  if (session.expires_at - now < SESSION_TTL - DAY) {
    await c.env.DB.prepare("UPDATE sessions SET expires_at = ? WHERE token_hash = ?")
      .bind(now + SESSION_TTL, tokenHash)
      .run();
  }
  c.set("user", { id: session.id, email: session.email });
  c.set("tokenHash", tokenHash);
  await next();
});

auth.get("/v1/session", requireUser, (c) => c.json({ user: c.get("user") }));

auth.delete("/v1/session", requireUser, async (c) => {
  await c.env.DB.prepare("DELETE FROM sessions WHERE token_hash = ?").bind(c.get("tokenHash")).run();
  return c.body(null, 204);
});

auth.post("/v1/password-reset", async (c) => {
  if (!resetsConfigured(c.env)) throw new ApiError(503, "reset_unavailable");
  const body = await readJson(c.req.raw);
  const email = normalizeEmail(body.email);
  if (!email) throw new ApiError(400, "invalid_email");

  // Counted per request whether or not the account exists, so the limit reveals nothing either.
  const limits: Limit[] = [{ key: `reset:${email}`, max: RESET_LIMIT_PER_EMAIL }];
  if (await isLimited(c.env.DB, limits, RESET_WINDOW)) throw new ApiError(429, "too_many_requests");
  await recordAttempt(c.env.DB, limits, RESET_WINDOW);

  const user = await c.env.DB.prepare("SELECT id FROM users WHERE email = ?").bind(email).first<{ id: string }>();
  if (user) {
    const token = randomToken();
    await c.env.DB.prepare("INSERT INTO password_resets (token_hash, user_id, expires_at) VALUES (?, ?, ?)")
      .bind(await sha256Hex(token), user.id, Date.now() + RESET_TTL)
      .run();
    const link = `${new URL(c.req.url).origin}/reset#${token}`;
    try {
      await sendResetEmail(c.env, email, link);
    } catch (error) {
      // Still 202: the answer must not depend on whether the account exists.
      console.error("Password reset email failed", error);
    }
  }
  return c.json({}, 202);
});

auth.post("/v1/password-reset/inspect", async (c) => {
  const reset = await findReset(c.env, await readJson(c.req.raw));
  return c.json({ email: reset.email });
});

auth.post("/v1/password-reset/complete", async (c) => {
  const body = await readJson(c.req.raw);
  const reset = await findReset(c.env, body);
  const authKey = parseAuthKey(body.authKey);
  // A new password signs every device out; the vault itself is untouched (it hangs on the master password).
  await c.env.DB.batch([
    c.env.DB.prepare("UPDATE users SET auth_hash = ? WHERE id = ?").bind(await hashAuthKey(authKey), reset.userId),
    c.env.DB.prepare("DELETE FROM sessions WHERE user_id = ?").bind(reset.userId),
    c.env.DB.prepare("DELETE FROM password_resets WHERE user_id = ?").bind(reset.userId),
  ]);
  return c.body(null, 204);
});

auth.get("/reset", (c) => {
  const nonce = randomToken(16);
  c.header(
    "Content-Security-Policy",
    `default-src 'none'; script-src 'nonce-${nonce}'; style-src 'nonce-${nonce}'; connect-src 'self'; base-uri 'none'; form-action 'none'; frame-ancestors 'none'`,
  );
  c.header("Referrer-Policy", "no-referrer");
  c.header("Cache-Control", "no-store");
  return c.html(resetPage(nonce));
});

function resetsConfigured(env: Bindings): boolean {
  return Boolean(env.RESEND_API_KEY && env.MAIL_FROM);
}

async function findReset(env: Bindings, body: Record<string, unknown>): Promise<{ userId: string; email: string }> {
  const token = typeof body.token === "string" ? body.token : "";
  if (!token) throw new ApiError(400, "invalid_request");
  const row = await env.DB.prepare(
    "SELECT r.user_id, u.email, r.expires_at FROM password_resets r JOIN users u ON u.id = r.user_id WHERE r.token_hash = ?",
  )
    .bind(await sha256Hex(token))
    .first<{ user_id: string; email: string; expires_at: number }>();
  if (!row || row.expires_at <= Date.now()) throw new ApiError(410, "reset_expired");
  return { userId: row.user_id, email: row.email };
}

function parseAuthKey(value: unknown): Uint8Array {
  const key = fromBase64(value);
  if (!key || key.length !== AUTH_KEY_BYTES) throw new ApiError(400, "invalid_request");
  return key;
}

async function openSession(env: Bindings, userId: string): Promise<string> {
  const token = randomToken();
  const now = Date.now();
  await env.DB.prepare("INSERT INTO sessions (token_hash, user_id, created_at, expires_at) VALUES (?, ?, ?, ?)")
    .bind(await sha256Hex(token), userId, now, now + SESSION_TTL)
    .run();
  return token;
}

// The auth key is already a slow, salted derivation; one salted SHA-256 here means a leaked table
// can't be replayed as credentials.
async function hashAuthKey(authKey: Uint8Array): Promise<string> {
  const salt = crypto.getRandomValues(new Uint8Array(16));
  return `sha256$${toBase64(salt)}$${toBase64(await saltedDigest(salt, authKey))}`;
}

async function verifyAuthKey(authKey: Uint8Array, stored: string): Promise<boolean> {
  const [scheme, saltB64, hashB64] = stored.split("$");
  const salt = fromBase64(saltB64);
  const expected = fromBase64(hashB64);
  if (scheme !== "sha256" || !salt || !expected) return false;
  return constantTimeEqual(await saltedDigest(salt, authKey), expected);
}

async function saltedDigest(salt: Uint8Array, authKey: Uint8Array): Promise<Uint8Array> {
  const input = new Uint8Array(salt.length + authKey.length);
  input.set(salt);
  input.set(authKey, salt.length);
  return sha256(input);
}

const DUMMY_HASH = "sha256$AAAAAAAAAAAAAAAAAAAAAA==$AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";

interface Limit {
  key: string;
  max: number;
}

function clientAddress(request: Request): string {
  return request.headers.get("CF-Connecting-IP") ?? "unknown";
}

async function isLimited(db: D1Database, limits: Limit[], window: number): Promise<boolean> {
  const placeholders = limits.map(() => "?").join(", ");
  const { results } = await db
    .prepare(`SELECT key, failures, window_start FROM login_failures WHERE key IN (${placeholders})`)
    .bind(...limits.map((limit) => limit.key))
    .all<{ key: string; failures: number; window_start: number }>();
  const cutoff = Date.now() - window;
  return results.some((row) => {
    const limit = limits.find((item) => item.key === row.key);
    return limit !== undefined && row.window_start > cutoff && row.failures >= limit.max;
  });
}

async function recordAttempt(db: D1Database, limits: Limit[], window: number): Promise<void> {
  const now = Date.now();
  const cutoff = now - window;
  await db.batch(
    limits.map((limit) =>
      db
        .prepare(
          `INSERT INTO login_failures (key, failures, window_start) VALUES (?1, 1, ?2)
           ON CONFLICT (key) DO UPDATE SET
             failures = CASE WHEN window_start <= ?3 THEN 1 ELSE failures + 1 END,
             window_start = CASE WHEN window_start <= ?3 THEN ?2 ELSE window_start END`,
        )
        .bind(limit.key, now, cutoff),
    ),
  );
}
