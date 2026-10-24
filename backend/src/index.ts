import { Hono } from "hono";
import { bodyLimit } from "hono/body-limit";
import { cors } from "hono/cors";
import { HTTPException } from "hono/http-exception";
import { auth } from "./auth";
import type { AppEnv, Bindings } from "./env";
import { ApiError, splitList } from "./support";
import { vault } from "./vault";

const app = new Hono<AppEnv>();

app.use("/v1/*", async (c, next) => {
  const allowed = splitList(c.env.ALLOWED_ORIGINS);
  return cors({
    origin: allowed.includes("*") || allowed.length === 0 ? "*" : allowed,
    allowHeaders: ["Authorization", "Content-Type"],
    allowMethods: ["GET", "POST", "DELETE", "OPTIONS"],
    maxAge: 86_400,
  })(c, next);
});

app.use(
  "/v1/*",
  bodyLimit({
    maxSize: 3 * 1024 * 1024,
    onError: (c) => c.json({ error: "payload_too_large" }, 413),
  }),
);

app.use("/v1/*", async (c, next) => {
  await next();
  c.header("Cache-Control", "no-store");
});

app.get("/", (c) => c.json({ name: "boveda-api", ok: true }));

app.route("/", auth);
app.route("/", vault);

app.notFound((c) => c.json({ error: "not_found" }, 404));

app.onError((error, c) => {
  if (error instanceof ApiError) return c.json({ error: error.code }, error.status);
  if (error instanceof HTTPException) return c.json({ error: "invalid_request" }, error.status);
  console.error("Unhandled error", error);
  return c.json({ error: "server_error" }, 500);
});

export default {
  fetch: app.fetch,
  /** Daily housekeeping (cron in wrangler.jsonc): expired sessions, reset links and rate-limit windows. */
  async scheduled(_controller, env) {
    const now = Date.now();
    await env.DB.batch([
      env.DB.prepare("DELETE FROM sessions WHERE expires_at <= ?").bind(now),
      env.DB.prepare("DELETE FROM password_resets WHERE expires_at <= ?").bind(now),
      env.DB.prepare("DELETE FROM login_failures WHERE window_start <= ?").bind(now - 24 * 60 * 60 * 1000),
    ]);
  },
} satisfies ExportedHandler<Bindings>;
