import { HTTPException } from "hono/http-exception";
import type { ContentfulStatusCode } from "hono/utils/http-status";

/**
 * Every failure the app knows how to explain. The Flutter data layer maps each code to a domain
 * error, so these strings are part of the API contract.
 */
export type ErrorCode =
  | "invalid_request"
  | "invalid_email"
  | "email_in_use"
  | "registration_closed"
  | "invalid_credentials"
  | "too_many_requests"
  | "unauthorized"
  | "vault_exists"
  | "vault_missing"
  | "reset_unavailable"
  | "reset_expired"
  | "not_found"
  | "payload_too_large";

export class ApiError extends HTTPException {
  constructor(status: ContentfulStatusCode, readonly code: ErrorCode) {
    super(status, { message: code });
  }
}

export const MINUTE = 60_000;
export const HOUR = 60 * MINUTE;
export const DAY = 24 * HOUR;

const encoder = new TextEncoder();

export function randomToken(bytes = 32): string {
  return toBase64Url(crypto.getRandomValues(new Uint8Array(bytes)));
}

export async function sha256(data: Uint8Array | string): Promise<Uint8Array> {
  const input = typeof data === "string" ? encoder.encode(data) : data;
  return new Uint8Array(await crypto.subtle.digest("SHA-256", input));
}

export async function sha256Hex(data: string): Promise<string> {
  return [...(await sha256(data))].map((b) => b.toString(16).padStart(2, "0")).join("");
}

/** Compares without leaking, through timing, how many leading bytes matched. */
export function constantTimeEqual(a: Uint8Array, b: Uint8Array): boolean {
  if (a.length !== b.length) return false;
  let diff = 0;
  for (let i = 0; i < a.length; i++) diff |= a[i] ^ b[i];
  return diff === 0;
}

export function toBase64(bytes: Uint8Array): string {
  let binary = "";
  for (const b of bytes) binary += String.fromCharCode(b);
  return btoa(binary);
}

export function toBase64Url(bytes: Uint8Array): string {
  return toBase64(bytes).replace(/\+/g, "-").replace(/\//g, "_").replace(/=+$/, "");
}

/** Strict standard base64 (what the app sends); null when [value] isn't valid base64. */
export function fromBase64(value: unknown): Uint8Array | null {
  if (typeof value !== "string" || value.length === 0 || value.length % 4 !== 0) return null;
  if (!/^[A-Za-z0-9+/]+={0,2}$/.test(value)) return null;
  try {
    const binary = atob(value);
    const bytes = new Uint8Array(binary.length);
    for (let i = 0; i < binary.length; i++) bytes[i] = binary.charCodeAt(i);
    return bytes;
  } catch {
    return null;
  }
}

export function normalizeEmail(value: unknown): string | null {
  if (typeof value !== "string") return null;
  const email = value.trim().toLowerCase();
  // Deliberately loose: one @, something on each side, a dot in the domain, no spaces.
  return email.length <= 254 && /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email) ? email : null;
}

export function splitList(value: string | undefined): string[] {
  return (value ?? "")
    .split(",")
    .map((item) => item.trim())
    .filter((item) => item.length > 0);
}

export async function readJson(request: Request): Promise<Record<string, unknown>> {
  try {
    const body = await request.json();
    if (body && typeof body === "object" && !Array.isArray(body)) return body as Record<string, unknown>;
  } catch {
    // Falls through to the error below.
  }
  throw new ApiError(400, "invalid_request");
}
