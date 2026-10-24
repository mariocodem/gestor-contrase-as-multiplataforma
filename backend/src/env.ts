/** Bindings from wrangler.jsonc (generated into worker-configuration.d.ts) plus optional secrets. */
export type Bindings = Env & {
  /** `npx wrangler secret put RESEND_API_KEY`; enables password-reset emails together with MAIL_FROM. */
  RESEND_API_KEY?: string;
};

export interface SessionUser {
  id: string;
  email: string;
}

export interface AppEnv {
  Bindings: Bindings;
  Variables: { user: SessionUser; tokenHash: string };
}
