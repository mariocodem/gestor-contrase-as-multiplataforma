-- Bóveda on D1. Everything sensitive arrives already encrypted on the device: the server stores
-- AES-256-GCM ciphertext (base64) and the public parameters needed to re-derive the vault key from
-- the master password, which never leaves the device.

CREATE TABLE users (
  id TEXT PRIMARY KEY,
  email TEXT NOT NULL UNIQUE COLLATE NOCASE,
  -- "sha256$<salt>$<hash>" over the device-derived auth key (never the account password itself).
  auth_hash TEXT NOT NULL,
  created_at INTEGER NOT NULL
);

CREATE TABLE sessions (
  -- SHA-256 of the bearer token; the token itself is only ever on the device.
  token_hash TEXT PRIMARY KEY,
  user_id TEXT NOT NULL REFERENCES users (id) ON DELETE CASCADE,
  created_at INTEGER NOT NULL,
  expires_at INTEGER NOT NULL
);
CREATE INDEX sessions_by_user ON sessions (user_id);

-- One vault per user: the wrapped vault key and the KDF parameters (stored so they can change).
CREATE TABLE vaults (
  user_id TEXT PRIMARY KEY REFERENCES users (id) ON DELETE CASCADE,
  version INTEGER NOT NULL,
  kdf TEXT NOT NULL,
  kdf_iterations INTEGER NOT NULL,
  salt TEXT NOT NULL,
  wrapped_key TEXT NOT NULL,
  -- Bumped by every entry write; devices sync by asking for what changed after their revision.
  revision INTEGER NOT NULL DEFAULT 0,
  created_at INTEGER NOT NULL
);

-- iv (12 bytes) || ciphertext || tag (16 bytes), with the entry id as authenticated data.
-- A deleted entry keeps its row (data NULL, deleted 1) so other devices learn about it.
CREATE TABLE entries (
  user_id TEXT NOT NULL REFERENCES vaults (user_id) ON DELETE CASCADE,
  id TEXT NOT NULL,
  v INTEGER NOT NULL DEFAULT 1,
  data TEXT,
  deleted INTEGER NOT NULL DEFAULT 0,
  revision INTEGER NOT NULL,
  updated_at INTEGER NOT NULL,
  PRIMARY KEY (user_id, id)
);
CREATE INDEX entries_by_revision ON entries (user_id, revision);

-- Each write takes the vault's next revision (see src/vault.ts); these keep the vault in step, so
-- one statement per change is enough (D1 counts queries per request).
CREATE TRIGGER entries_bump_vault_on_insert AFTER INSERT ON entries
BEGIN
  UPDATE vaults SET revision = NEW.revision WHERE user_id = NEW.user_id;
END;

CREATE TRIGGER entries_bump_vault_on_update AFTER UPDATE OF revision ON entries
BEGIN
  UPDATE vaults SET revision = NEW.revision WHERE user_id = NEW.user_id;
END;

-- Failed sign-ins per email and per address, to slow down password guessing.
CREATE TABLE login_failures (
  key TEXT PRIMARY KEY,
  failures INTEGER NOT NULL,
  window_start INTEGER NOT NULL
);

CREATE TABLE password_resets (
  token_hash TEXT PRIMARY KEY,
  user_id TEXT NOT NULL REFERENCES users (id) ON DELETE CASCADE,
  expires_at INTEGER NOT NULL
);
