/**
 * The page a reset email links to. It derives the auth key in the browser exactly as the app does
 * (PBKDF2-HMAC-SHA256, 600 000 iterations, salt = SHA-256("boveda-auth-v1:" + email)), so the new
 * account password never reaches the server either. Styled after the app: brushed steel, graphite
 * emblem, brass for the one action.
 */
export function resetPage(nonce: string): string {
  return `<!doctype html>
<html lang="es">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<meta name="robots" content="noindex">
<title>Bóveda · Nueva contraseña</title>
<style nonce="${nonce}">
:root {
  color-scheme: light dark;
  --ground: #F1F3F5; --ink: #191C1F; --muted: #434A51; --hairline: #737A82;
  --brass: #876214; --on-brass: #FFFFFF; --shell: #20262C; --indicator: #E9C46A;
  --error: #B3261E; --panel: #DFE3E7;
}
@media (prefers-color-scheme: dark) {
  :root {
    --ground: #101316; --ink: #E1E5E9; --muted: #BEC6CD; --hairline: #899198;
    --brass: #E9C46A; --on-brass: #3D2E00; --shell: #1B2025; --error: #F2B8B5; --panel: #252A2E;
  }
}
* { box-sizing: border-box; }
body {
  margin: 0; min-height: 100vh; display: grid; place-items: center; padding: 32px 24px;
  background: var(--ground); color: var(--ink);
  font: 400 16px/24px "Atkinson Hyperlegible Next", system-ui, sans-serif; letter-spacing: 0.15px;
}
main { width: 100%; max-width: 440px; display: flex; flex-direction: column; align-items: center; text-align: center; }
h1 { font-size: 23px; line-height: 30px; font-weight: 600; margin: 24px 0 8px; }
p { margin: 0; color: var(--muted); }
form { width: 100%; margin-top: 24px; display: flex; flex-direction: column; gap: 12px; text-align: left; }
label { font-size: 12px; line-height: 16px; font-weight: 600; letter-spacing: 0.3px; color: var(--muted); }
input {
  width: 100%; height: 56px; padding: 0 16px; margin-top: 4px; border-radius: 6px;
  border: 1px solid var(--hairline); background: transparent; color: var(--ink); font: inherit;
}
input:focus { outline: 2px solid var(--brass); outline-offset: -1px; border-color: transparent; }
button {
  height: 52px; margin-top: 12px; border: 0; border-radius: 999px; cursor: pointer;
  background: var(--brass); color: var(--on-brass); font-family: inherit; font-weight: 600; font-size: 14px; line-height: 20px; letter-spacing: 0.1px;
}
button:disabled { opacity: 0.6; cursor: progress; }
.message { min-height: 20px; font-size: 14px; line-height: 20px; }
.message.error { color: var(--error); }
.note { margin-top: 16px; padding: 16px; border-radius: 14px; background: var(--panel); color: var(--ink); font-size: 14px; line-height: 20px; text-align: left; }
.cap { fill: var(--shell); }
.lock { fill: none; stroke: var(--indicator); stroke-width: 80; }
.lock-dot { fill: var(--indicator); }
[hidden] { display: none !important; }
</style>
</head>
<body>
<main>
  <svg width="76" height="76" viewBox="0 0 76 76" aria-hidden="true">
    <mask id="ring"><rect width="76" height="76" fill="#fff"/><circle cx="38" cy="12.1" r="5.7" fill="#000"/></mask>
    <g mask="url(#ring)" class="cap">
      <rect width="76" height="63.8" rx="22.8"/>
      <rect x="28.1" y="57.7" width="19.8" height="18.3" rx="3.8"/>
    </g>
    <g transform="translate(22.8 28.1) scale(0.0317)" class="lock">
      <rect x="200" y="360" width="560" height="480" rx="40"/>
      <path d="M320 320 V240 A160 160 0 0 1 640 240 V330" stroke-linecap="round"/>
      <circle cx="480" cy="600" r="80" class="lock-dot" stroke="none"/>
    </g>
  </svg>
  <h1 id="title">Nueva contraseña de la cuenta</h1>
  <p id="subtitle">Comprobando el enlace…</p>

  <form id="form" hidden novalidate>
    <div>
      <label for="password">Contraseña nueva</label>
      <input id="password" type="password" autocomplete="new-password" minlength="8" required>
    </div>
    <div>
      <label for="confirmation">Repítela</label>
      <input id="confirmation" type="password" autocomplete="new-password" minlength="8" required>
    </div>
    <div id="message" class="message error" role="status" aria-live="polite"></div>
    <button id="submit" type="submit">Guardar contraseña</button>
  </form>
  <div class="note" id="note" hidden>Tu bóveda no cambia: se sigue abriendo con tu contraseña maestra. Al guardar, se cerrará la sesión en todos tus dispositivos.</div>
</main>
<script nonce="${nonce}">
(() => {
  const token = decodeURIComponent(location.hash.slice(1));
  history.replaceState(null, "", location.pathname);
  const $ = (id) => document.getElementById(id);
  let email = null;

  const post = (path, body) => fetch(path, {
    method: "POST", headers: { "Content-Type": "application/json" }, body: JSON.stringify(body),
  });

  const fail = (text) => {
    $("form").hidden = true; $("note").hidden = true;
    $("subtitle").textContent = text;
  };

  async function deriveAuthKey(password) {
    const enc = new TextEncoder();
    const salt = await crypto.subtle.digest("SHA-256", enc.encode("boveda-auth-v1:" + email));
    const base = await crypto.subtle.importKey("raw", enc.encode(password), "PBKDF2", false, ["deriveBits"]);
    const bits = await crypto.subtle.deriveBits({ name: "PBKDF2", hash: "SHA-256", salt, iterations: 600000 }, base, 256);
    return btoa(String.fromCharCode(...new Uint8Array(bits)));
  }

  (async () => {
    if (!token) return fail("Este enlace no es válido. Pide otro desde la app.");
    try {
      const response = await post("/v1/password-reset/inspect", { token });
      if (!response.ok) return fail("El enlace caducó o ya se usó. Pide otro desde la app.");
      email = (await response.json()).email;
      $("subtitle").textContent = "Para " + email + ".";
      $("form").hidden = false; $("note").hidden = false;
      $("password").focus();
    } catch {
      fail("Sin conexión. Comprueba la red y vuelve a abrir el enlace.");
    }
  })();

  $("form").addEventListener("submit", async (event) => {
    event.preventDefault();
    const password = $("password").value;
    if (password.length < 8) return void ($("message").textContent = "Usa al menos 8 caracteres.");
    if (password !== $("confirmation").value) return void ($("message").textContent = "Las contraseñas no coinciden.");
    $("message").textContent = "";
    $("submit").disabled = true;
    $("submit").textContent = "Guardando…";
    try {
      const response = await post("/v1/password-reset/complete", { token, authKey: await deriveAuthKey(password) });
      if (!response.ok) return fail("El enlace caducó o ya se usó. Pide otro desde la app.");
      $("title").textContent = "Contraseña cambiada";
      fail("Vuelve a la app e inicia sesión con tu contraseña nueva.");
    } catch {
      $("message").textContent = "Sin conexión. Inténtalo de nuevo.";
      $("submit").disabled = false;
      $("submit").textContent = "Guardar contraseña";
    }
  });
})();
</script>
</body>
</html>`;
}
