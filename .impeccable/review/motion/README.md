# Motion evidence (Pixel_10 emulator, API 37, emulated GPU)

Contact sheets cut from `adb screenrecord` videos. Frames read left to right, top to bottom.
"Nx" means the system animator duration scale was set to N so the emulator (median 36 ms per
frame, p99 ~400 ms) could record the shape of each animation; real-time smoothness was NOT
measurable on this emulator and must be checked on hardware.

| File | What it shows |
|---|---|
| keycap-flight-list-to-detail-4x.png | Shared-element key cap leaving the "Banco" row and landing in the detail header (frames ~26-28 hold the intermediate bounds). Recorded after the detail was made to start Loaded. |
| detail-to-list-return-4x-before-list-fix.png | Return path recorded BEFORE VaultListViewModel became Eagerly: shows the stale "Tu bóveda está vacía" frame that motivated the fix. Kept as history, not as the current state. |
| unlock-shackle-opens-5x.png | Emblem padlock: closed -> shackle lifting -> open while the lock screen leaves. |
| lock-shackle-closes-5x.png | Lock screen arriving with the shackle up, then seated. |
| lock-transition-overview-5x.png | Vault -> lock screen cross-fade. |
| wrong-password-swing-1x-first-amplitude.png | Key swinging on its ring after a rejected master password (first amplitude; initial velocity was raised from 190 to 340 deg/s afterwards). |
| generator-tumbler-roll-4x.png | "Generar otra": each character rolls up through its own clipped window, left to right. |
| reveal-password-tumbler-4x.png | Mask dots rolling out as the password rolls in (detail screen). |
| copy-button-confirmation-4x.png | Copy button: icon -> check, label rolls to "Contraseña copiada" (the Android 13+ clipboard overlay covers its left part). |
| nav-bar-slides-away-4x.png / nav-bar-slides-back-4x.png | Navigation bar sliding out under the entering detail (its copy button rides down) and back in on return (FAB rises with it). |
| strength-meter-typing-1x.png | Strength meter opening its line and stepping up while the master password is typed. |
