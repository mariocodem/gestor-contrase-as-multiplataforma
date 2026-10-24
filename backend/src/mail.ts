import type { Bindings } from "./env";

/** Sends the reset link through Resend (https://resend.com). Throws when the provider refuses. */
export async function sendResetEmail(env: Bindings, to: string, link: string): Promise<void> {
  const response = await fetch("https://api.resend.com/emails", {
    method: "POST",
    headers: { Authorization: `Bearer ${env.RESEND_API_KEY}`, "Content-Type": "application/json" },
    body: JSON.stringify({
      from: env.MAIL_FROM,
      to: [to],
      subject: "Restablece la contraseña de tu cuenta de Bóveda",
      text: [
        "Alguien (esperamos que tú) pidió cambiar la contraseña de la cuenta de Bóveda.",
        "",
        `Abre este enlace en la próxima hora para elegir una nueva: ${link}`,
        "",
        "Tu bóveda no cambia: se sigue abriendo con tu contraseña maestra.",
        "Si no lo pediste tú, ignora este correo.",
      ].join("\n"),
      html: `<p>Alguien (esperamos que tú) pidió cambiar la contraseña de la cuenta de Bóveda.</p>
<p><a href="${link}">Elegir una contraseña nueva</a> (el enlace caduca en una hora).</p>
<p>Tu bóveda no cambia: se sigue abriendo con tu contraseña maestra.<br>Si no lo pediste tú, ignora este correo.</p>`,
    }),
  });
  if (!response.ok) throw new Error(`Resend responded ${response.status}: ${await response.text()}`);
}
