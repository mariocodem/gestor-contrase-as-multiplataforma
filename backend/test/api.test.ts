import { env, exports } from "cloudflare:workers";
import { describe, expect, it } from "vitest";

const BASE = "https://boveda.test";

function randomBase64(bytes: number): string {
  return btoa(String.fromCharCode(...crypto.getRandomValues(new Uint8Array(bytes))));
}

async function call(method: string, path: string, body?: unknown, token?: string, headers: Record<string, string> = {}) {
  const response = await exports.default.fetch(
    new Request(BASE + path, {
      method,
      headers: {
        ...(body === undefined ? {} : { "Content-Type": "application/json" }),
        ...(token ? { Authorization: `Bearer ${token}` } : {}),
        ...headers,
      },
      body: body === undefined ? undefined : JSON.stringify(body),
    }),
  );
  const text = await response.text();
  return { status: response.status, json: text ? JSON.parse(text) : null, headers: response.headers };
}

let accounts = 0;
async function register(authKey = randomBase64(32)) {
  const email = `persona${++accounts}@example.com`;
  const { status, json } = await call("POST", "/v1/register", { email, authKey });
  expect(status).toBe(201);
  return { email, authKey, token: json.token as string, userId: json.user.id as string };
}

function vaultMeta() {
  return {
    version: 1,
    kdf: "PBKDF2WithHmacSHA256",
    kdfIterations: 600_000,
    salt: randomBase64(16),
    wrappedKey: randomBase64(60),
  };
}

const ciphertext = () => randomBase64(80);

describe("accounts", () => {
  it("registers, signs in with the same auth key and rejects another", async () => {
    const account = await register();

    const login = await call("POST", "/v1/login", { email: account.email.toUpperCase(), authKey: account.authKey });
    expect(login.status).toBe(200);
    expect(login.json.user).toEqual({ id: account.userId, email: account.email });

    const wrong = await call("POST", "/v1/login", { email: account.email, authKey: randomBase64(32) });
    expect(wrong).toMatchObject({ status: 401, json: { error: "invalid_credentials" } });
  });

  it("refuses a second account with the same email and malformed input", async () => {
    const account = await register();

    expect((await call("POST", "/v1/register", { email: account.email, authKey: randomBase64(32) })).json).toEqual({
      error: "email_in_use",
    });
    expect((await call("POST", "/v1/register", { email: "no-arroba", authKey: randomBase64(32) })).json).toEqual({
      error: "invalid_email",
    });
    expect((await call("POST", "/v1/register", { email: "otra@example.com", authKey: randomBase64(16) })).status).toBe(400);
  });

  it("only lets the allowed emails register when ALLOWED_EMAILS is set", async () => {
    const previous = env.ALLOWED_EMAILS;
    env.ALLOWED_EMAILS = "dueno@example.com";
    try {
      const closed = await call("POST", "/v1/register", { email: "intruso@example.com", authKey: randomBase64(32) });
      expect(closed).toMatchObject({ status: 403, json: { error: "registration_closed" } });
      const open = await call("POST", "/v1/register", { email: "Dueno@Example.com", authKey: randomBase64(32) });
      expect(open.status).toBe(201);
    } finally {
      env.ALLOWED_EMAILS = previous;
    }
  });

  it("slows down password guessing per email", async () => {
    const account = await register();
    for (let i = 0; i < 10; i++) {
      await call("POST", "/v1/login", { email: account.email, authKey: randomBase64(32) });
    }

    const blocked = await call("POST", "/v1/login", { email: account.email, authKey: account.authKey });
    expect(blocked).toMatchObject({ status: 429, json: { error: "too_many_requests" } });
  });

  it("resolves the session and forgets it on sign out", async () => {
    const account = await register();

    expect((await call("GET", "/v1/session", undefined, account.token)).json.user.email).toBe(account.email);
    expect((await call("DELETE", "/v1/session", undefined, account.token)).status).toBe(204);
    expect(await call("GET", "/v1/session", undefined, account.token)).toMatchObject({
      status: 401,
      json: { error: "unauthorized" },
    });
  });

  it("says password resets are not configured without a mail provider", async () => {
    const reset = await call("POST", "/v1/password-reset", { email: "alguien@example.com" });
    expect(reset).toMatchObject({ status: 503, json: { error: "reset_unavailable" } });
  });

  it("completes a reset with a valid link and signs every device out", async () => {
    const account = await register();
    const token = "token-de-prueba";
    const tokenHash = [...new Uint8Array(await crypto.subtle.digest("SHA-256", new TextEncoder().encode(token)))]
      .map((b) => b.toString(16).padStart(2, "0"))
      .join("");
    await env.DB.prepare("INSERT INTO password_resets (token_hash, user_id, expires_at) VALUES (?, ?, ?)")
      .bind(tokenHash, account.userId, Date.now() + 60_000)
      .run();

    expect((await call("POST", "/v1/password-reset/inspect", { token })).json).toEqual({ email: account.email });
    const newKey = randomBase64(32);
    expect((await call("POST", "/v1/password-reset/complete", { token, authKey: newKey })).status).toBe(204);

    expect((await call("GET", "/v1/session", undefined, account.token)).status).toBe(401);
    expect((await call("POST", "/v1/login", { email: account.email, authKey: newKey })).status).toBe(200);
    expect((await call("POST", "/v1/password-reset/inspect", { token })).status).toBe(410);
  });

  it("serves the reset page with a strict content security policy", async () => {
    const response = await exports.default.fetch(new Request(`${BASE}/reset`));
    expect(response.status).toBe(200);
    expect(response.headers.get("Content-Security-Policy")).toContain("default-src 'none'");
    expect(await response.text()).toContain("boveda-auth-v1:");
  });
});

describe("vault", () => {
  it("needs a session", async () => {
    expect((await call("GET", "/v1/vault")).status).toBe(401);
    expect((await call("POST", "/v1/vault/sync", { since: 0 }, "token-inventado")).status).toBe(401);
  });

  it("creates the vault once and returns its parameters", async () => {
    const { token } = await register();
    expect(await call("GET", "/v1/vault", undefined, token)).toMatchObject({ status: 404, json: { error: "vault_missing" } });

    const meta = vaultMeta();
    expect((await call("POST", "/v1/vault", meta, token)).status).toBe(201);
    expect((await call("POST", "/v1/vault", vaultMeta(), token)).json).toEqual({ error: "vault_exists" });

    const stored = await call("GET", "/v1/vault", undefined, token);
    expect(stored.json).toMatchObject({ ...meta, revision: 0 });
  });

  it("rejects vault parameters the app could never have produced", async () => {
    const { token } = await register();
    expect((await call("POST", "/v1/vault", { ...vaultMeta(), kdfIterations: 1_000 }, token)).status).toBe(400);
    expect((await call("POST", "/v1/vault", { ...vaultMeta(), wrappedKey: randomBase64(32) }, token)).status).toBe(400);
  });

  it("syncs changes between two devices, deletions included", async () => {
    const account = await register();
    await call("POST", "/v1/vault", vaultMeta(), account.token);
    const phone = account.token;
    const laptop = (await call("POST", "/v1/login", { email: account.email, authKey: account.authKey })).json.token;

    const first = ciphertext();
    const pushed = await call(
      "POST",
      "/v1/vault/sync",
      { since: 0, changes: [{ op: "put", id: "entryA", v: 1, data: first }, { op: "put", id: "entryB", v: 1, data: ciphertext() }] },
      phone,
    );
    expect(pushed.json.revision).toBe(2);
    expect(pushed.json.entries.map((e: { id: string }) => e.id)).toEqual(["entryA", "entryB"]);

    const pulled = await call("POST", "/v1/vault/sync", { since: 0 }, laptop);
    expect(pulled.json.entries.find((e: { id: string }) => e.id === "entryA")).toMatchObject({ data: first, deleted: false });

    await call("POST", "/v1/vault/sync", { since: 2, changes: [{ op: "delete", id: "entryA" }] }, laptop);

    const delta = await call("POST", "/v1/vault/sync", { since: 2 }, phone);
    expect(delta.json).toMatchObject({ revision: 3, reset: false });
    expect(delta.json.entries).toEqual([
      expect.objectContaining({ id: "entryA", data: null, deleted: true, revision: 3 }),
    ]);

    const upToDate = await call("POST", "/v1/vault/sync", { since: 3 }, phone);
    expect(upToDate.json).toMatchObject({ revision: 3, entries: [] });
    expect((await call("GET", "/v1/vault", undefined, phone)).json.revision).toBe(3);
  });

  it("starts a device over when it claims a revision the server never reached", async () => {
    const { token } = await register();
    await call("POST", "/v1/vault", vaultMeta(), token);
    await call("POST", "/v1/vault/sync", { since: 0, changes: [{ op: "put", id: "only", data: ciphertext() }] }, token);

    const ahead = await call("POST", "/v1/vault/sync", { since: 99 }, token);
    expect(ahead.json).toMatchObject({ revision: 1, reset: true });
    expect(ahead.json.entries).toHaveLength(1);
  });

  it("validates changes and caps how many arrive at once", async () => {
    const { token } = await register();
    await call("POST", "/v1/vault", vaultMeta(), token);

    const badId = await call("POST", "/v1/vault/sync", { since: 0, changes: [{ op: "put", id: "../x", data: ciphertext() }] }, token);
    expect(badId.status).toBe(400);
    const tooShort = await call("POST", "/v1/vault/sync", { since: 0, changes: [{ op: "put", id: "x", data: randomBase64(20) }] }, token);
    expect(tooShort.status).toBe(400);
    const tooMany = Array.from({ length: 41 }, (_, i) => ({ op: "delete", id: `e${i}` }));
    expect((await call("POST", "/v1/vault/sync", { since: 0, changes: tooMany }, token)).status).toBe(413);
  });

  it("keeps each account's entries to itself", async () => {
    const ana = await register();
    const bea = await register();
    await call("POST", "/v1/vault", vaultMeta(), ana.token);
    await call("POST", "/v1/vault", vaultMeta(), bea.token);
    await call("POST", "/v1/vault/sync", { since: 0, changes: [{ op: "put", id: "same-id", data: ciphertext() }] }, ana.token);

    expect((await call("POST", "/v1/vault/sync", { since: 0 }, bea.token)).json.entries).toEqual([]);
  });

  it("answers browser preflights for the web build", async () => {
    const preflight = await exports.default.fetch(
      new Request(`${BASE}/v1/vault/sync`, {
        method: "OPTIONS",
        headers: { Origin: "https://app.example", "Access-Control-Request-Method": "POST" },
      }),
    );
    expect(preflight.status).toBe(204);
    expect(preflight.headers.get("Access-Control-Allow-Headers")).toContain("Authorization");
  });
});
