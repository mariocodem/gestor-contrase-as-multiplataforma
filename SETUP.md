# Bóveda: puesta en marcha

Estructura:

```
pubspec.yaml            app Flutter (raíz de composición: lib/main.dart, lib/config.dart)
packages/domain         reglas de negocio (Dart puro)
packages/data           cifrado, cliente del Worker, copia local y sincronización
packages/designsystem   tema acero y latón, fuentes, iconos, componentes
packages/presentation   pantallas y cubits
backend/                Worker de Cloudflare + D1
legacy/android-compose  proyecto Kotlin anterior (solo como referencia; bórralo cuando quieras)
```

## 1. Herramientas (una vez)

```sh
# Flutter ya está en ~/development/flutter; añádelo al PATH (p. ej. en ~/.bashrc):
export PATH="$HOME/development/flutter/bin:$PATH"

# Escritorio Linux (necesario para `flutter run -d linux`):
sudo pacman -S clang cmake ninja

# Android: Gradle no admite el JDK 27 del sistema; usa el JDK 25 que ya tienes:
flutter config --jdk-dir "$HOME/.gradle/jdks/eclipse_adoptium-25-amd64-linux.2"
flutter doctor --android-licenses
```

iOS y macOS solo se compilan en un Mac (Xcode). La web se compila sin nada más; para probarla con
`flutter run -d chrome` hace falta Chrome o Chromium.

## 2. Backend en Cloudflare (D1 + Worker)

```sh
cd backend
npx wrangler login                                   # abre el navegador
npx wrangler d1 create boveda                        # copia el "database_id" que imprime
# Pega ese id en wrangler.jsonc → d1_databases[0].database_id
npm run db:migrate:remote                            # crea las tablas en D1
```

Edita `wrangler.jsonc` → `vars`:

- `ALLOWED_EMAILS`: **pon tu correo** (si lo dejas vacío, cualquiera con la URL puede registrarse).
- `ALLOWED_ORIGINS`: déjalo en `"*"` o pon el dominio donde publiques la versión web.

```sh
npm run deploy                                       # imprime https://boveda-api.<tu-subdominio>.workers.dev
```

Opcional, correo para "Olvidé la contraseña de la cuenta" (con [Resend](https://resend.com) y un dominio verificado):

```sh
npx wrangler secret put RESEND_API_KEY
# y en wrangler.jsonc: "MAIL_FROM": "Bóveda <boveda@tu-dominio.com>", luego npm run deploy
```

Sin esto, la app avisa de que el restablecimiento no está configurado. La contraseña maestra nunca
se puede recuperar (por diseño).

## 3. Apuntar la app a tu Worker

```sh
cp config/prod.example.json config/prod.json          # pon la URL del paso anterior
flutter run --dart-define-from-file=config/prod.json  # -d android | linux | chrome | windows | macos | ios
```

Desarrollo local sin Cloudflare: `cd backend && npm run db:migrate:local && npm run dev`, y en otra
terminal `flutter run` (sin --dart-define usa http://localhost:8787, o 10.0.2.2 en el emulador Android).

## 4. Publicar

- Android: cambia `applicationId` (`com.example.boveda`) por un dominio tuyo y configura tu propia firma
  de release en `android/app/build.gradle.kts` (ahora usa la clave de debug).
- Capturas de pantalla en debug (FLAG_SECURE desactivado): `flutter run --android-project-arg=boveda.allowScreenshots=true`.

## Tests

```sh
(cd packages/domain && dart test)
(cd packages/data && flutter test)
(cd packages/presentation && flutter test)
(cd backend && npm test && npm run typecheck)
```
