# Product

<!-- impeccable:product-schema 1 -->

## Platform

android

## Users

One person (the developer) keeping their own passwords. They use it on their own Android phone in short bursts: to look up and copy a username or password while signing in to a site or app, and to create a strong password when opening a new account. Several devices may share the same vault through the same account.

## Product Purpose

"Bóveda" is a personal password manager with a built-in password generator. Success means: unlocking takes seconds (biometrics when available), the right entry is found and copied in two or three taps, and every new account gets a strong generated password instead of a reused one.

## Positioning

Zero-knowledge sync on infrastructure the user controls. Entries are encrypted on the device (AES-256-GCM, vault key wrapped with PBKDF2-HMAC-SHA256 from the master password) before they reach the user's own Firebase project; Firestore only ever stores ciphertext and the master password never leaves the phone.

## Operating Context

- Firebase Auth (email + account password) decides whose documents can be read; a separate master password decrypts the vault and cannot be recovered.
- Typical session: unlock, search, copy, switch to another app. The clipboard copy is marked sensitive and cleared automatically; the vault locks itself after a while in the background.
- Works offline from Firestore's local cache; writes sync later.
- Screens are hidden from screenshots and the recents preview (FLAG_SECURE).

## Capabilities and Constraints

- Confirmed: account sign-in/registration/reset, create and unlock the vault, optional strong-biometric unlock (Android Keystore), auto-lock, list with accent-insensitive search, create/edit/delete entries (title, username, password, URL, notes).
- Generator (confirmed scope): configurable random passwords (length, uppercase, lowercase, digits, symbols, avoid ambiguous characters) and a strength meter (entropy and estimated crack time) that also rates passwords typed by hand.
- Not wanted for now: passphrase generator, generated-password history.
- Undecided: Android Autofill service, import/export.
- The existing Firestore layout (`users/{uid}` meta + `users/{uid}/entries/{id}` ciphertext) and crypto parameters must stay readable: real data may already exist.
- UI language: Spanish. minSdk 26, targetSdk 37, Jetpack Compose + Material 3.

## Brand Commitments

- Product name shown to the user: "Bóveda".

## Evidence on Hand

None. No testimonials, metrics or store assets exist; do not invent them.

## Product Principles

1. The secret is the user's alone: nothing readable leaves the device, and no shortcut weakens that.
2. Speed to the copied password beats feature breadth.
3. Make the strong choice the easy one: generating a good password is one tap wherever a password is typed.
4. Honest security language: say what is protected and what is lost if the master password is forgotten, without alarmism or jargon.

## Accessibility & Inclusion

Standard Android expectations: TalkBack labels on every icon action, 48 dp touch targets, system font scaling, light and dark themes.
