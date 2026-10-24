import { Hono } from "hono";
import { requireUser } from "./auth";
import type { AppEnv } from "./env";
import { ApiError, fromBase64, readJson } from "./support";

/** Matches the app's crypto: AES-256-GCM, iv 12 bytes, tag 16 bytes. */
const IV_BYTES = 12;
const TAG_BYTES = 16;
const WRAPPED_KEY_BYTES = IV_BYTES + 32 + TAG_BYTES;
const MIN_ITERATIONS = 100_000;
const MAX_ITERATIONS = 10_000_000;
const MAX_ENTRY_BYTES = 48 * 1024;
const ENTRY_ID = /^[A-Za-z0-9_-]{1,64}$/;

/**
 * Changes accepted per sync. Each one is a single D1 query and the free plan allows 50 per
 * request, so the app sends larger queues in chunks of this size.
 */
export const MAX_CHANGES_PER_SYNC = 40;

interface VaultRow {
  version: number;
  kdf: string;
  kdf_iterations: number;
  salt: string;
  wrapped_key: string;
  revision: number;
  created_at: number;
}

interface EntryRow {
  id: string;
  v: number;
  data: string | null;
  deleted: number;
  revision: number;
  updated_at: number;
}

type Change = { op: "put"; id: string; v: number; data: string } | { op: "delete"; id: string };

export const vault = new Hono<AppEnv>();

vault.use("/v1/vault", requireUser);
vault.use("/v1/vault/*", requireUser);

vault.get("/v1/vault", async (c) => {
  const row = await c.env.DB.prepare(
    "SELECT version, kdf, kdf_iterations, salt, wrapped_key, revision, created_at FROM vaults WHERE user_id = ?",
  )
    .bind(c.get("user").id)
    .first<VaultRow>();
  if (!row) throw new ApiError(404, "vault_missing");
  return c.json({
    version: row.version,
    kdf: row.kdf,
    kdfIterations: row.kdf_iterations,
    salt: row.salt,
    wrappedKey: row.wrapped_key,
    revision: row.revision,
    createdAt: row.created_at,
  });
});

/** Creates the vault once; never overwrites one, so a second device can't replace the key. */
vault.post("/v1/vault", async (c) => {
  const body = await readJson(c.req.raw);
  const iterations = body.kdfIterations;
  const salt = fromBase64(body.salt);
  const wrappedKey = fromBase64(body.wrappedKey);
  if (
    body.version !== 1 ||
    body.kdf !== "PBKDF2WithHmacSHA256" ||
    typeof iterations !== "number" ||
    !Number.isInteger(iterations) ||
    iterations < MIN_ITERATIONS ||
    iterations > MAX_ITERATIONS ||
    !salt ||
    salt.length < 16 ||
    salt.length > 64 ||
    wrappedKey?.length !== WRAPPED_KEY_BYTES
  ) {
    throw new ApiError(400, "invalid_request");
  }

  const createdAt = Date.now();
  const created = await c.env.DB.prepare(
    `INSERT INTO vaults (user_id, version, kdf, kdf_iterations, salt, wrapped_key, revision, created_at)
     VALUES (?, 1, 'PBKDF2WithHmacSHA256', ?, ?, ?, 0, ?) ON CONFLICT (user_id) DO NOTHING RETURNING user_id`,
  )
    .bind(c.get("user").id, iterations, body.salt, body.wrappedKey, createdAt)
    .first();
  if (!created) throw new ApiError(409, "vault_exists");
  return c.json({ revision: 0, createdAt }, 201);
});

/**
 * One round trip per sync: applies the device's queued changes in order (last write wins), then
 * returns every entry that changed after the device's revision, deletions included.
 */
vault.post("/v1/vault/sync", async (c) => {
  const userId = c.get("user").id;
  const body = await readJson(c.req.raw);
  const since = body.since ?? 0;
  if (typeof since !== "number" || !Number.isInteger(since) || since < 0) throw new ApiError(400, "invalid_request");
  const changes = parseChanges(body.changes ?? []);

  const current = await c.env.DB.prepare("SELECT revision FROM vaults WHERE user_id = ?")
    .bind(userId)
    .first<{ revision: number }>();
  if (!current) throw new ApiError(404, "vault_missing");

  let revision = current.revision;
  if (changes.length > 0) {
    const now = Date.now();
    const nextRevision = "(SELECT revision + 1 FROM vaults WHERE user_id = ?1)";
    const writes = changes.map((change) =>
      change.op === "put"
        ? c.env.DB.prepare(
            `INSERT INTO entries (user_id, id, v, data, deleted, revision, updated_at)
             VALUES (?1, ?2, ?3, ?4, 0, ${nextRevision}, ?5)
             ON CONFLICT (user_id, id) DO UPDATE SET
               v = excluded.v, data = excluded.data, deleted = 0,
               revision = excluded.revision, updated_at = excluded.updated_at`,
          ).bind(userId, change.id, change.v, change.data, now)
        : c.env.DB.prepare(
            `INSERT INTO entries (user_id, id, v, data, deleted, revision, updated_at)
             VALUES (?1, ?2, 1, NULL, 1, ${nextRevision}, ?3)
             ON CONFLICT (user_id, id) DO UPDATE SET
               data = NULL, deleted = 1, revision = excluded.revision, updated_at = excluded.updated_at`,
          ).bind(userId, change.id, now),
    );
    // The batch is one transaction; its last statement reads the revision those writes reached.
    const results = await c.env.DB.batch([
      ...writes,
      c.env.DB.prepare("SELECT revision FROM vaults WHERE user_id = ?").bind(userId),
    ]);
    revision = (results.at(-1)?.results[0] as { revision: number }).revision;
  }

  // A device ahead of the server (a restored database) starts over from nothing.
  const reset = since > current.revision;
  const { results } = await c.env.DB.prepare(
    "SELECT id, v, data, deleted, revision, updated_at FROM entries WHERE user_id = ? AND revision > ? ORDER BY revision",
  )
    .bind(userId, reset ? 0 : since)
    .all<EntryRow>();

  return c.json({
    // Another device may have written in between; the rows returned carry those revisions too.
    revision: results.reduce((max, row) => Math.max(max, row.revision), revision),
    reset,
    entries: results.map((row) => ({
      id: row.id,
      v: row.v,
      data: row.data,
      deleted: row.deleted === 1,
      revision: row.revision,
      updatedAt: row.updated_at,
    })),
  });
});

function parseChanges(value: unknown): Change[] {
  if (!Array.isArray(value)) throw new ApiError(400, "invalid_request");
  if (value.length > MAX_CHANGES_PER_SYNC) throw new ApiError(413, "payload_too_large");
  return value.map((raw): Change => {
    const item = raw as Record<string, unknown>;
    if (typeof item?.id !== "string" || !ENTRY_ID.test(item.id)) throw new ApiError(400, "invalid_request");
    if (item.op === "delete") return { op: "delete", id: item.id };
    if (item.op !== "put") throw new ApiError(400, "invalid_request");
    const v = item.v ?? 1;
    const data = fromBase64(item.data);
    if (typeof v !== "number" || !Number.isInteger(v) || !data || data.length <= IV_BYTES + TAG_BYTES) {
      throw new ApiError(400, "invalid_request");
    }
    if (data.length > MAX_ENTRY_BYTES) throw new ApiError(413, "payload_too_large");
    return { op: "put", id: item.id, v, data: item.data as string };
  });
}
