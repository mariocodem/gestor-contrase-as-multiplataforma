package com.example.myapplication.domain.model

/** How long the vault stays unlocked while the app is in the background. */
enum class AutoLockTimeout(val millis: Long) {
    IMMEDIATELY(0L),
    SECONDS_30(30_000L),
    MINUTE_1(60_000L),
    MINUTES_5(300_000L),
    MINUTES_15(900_000L),
}

data class AppSettings(
    val autoLock: AutoLockTimeout = AutoLockTimeout.MINUTE_1,
    /** Use the wallpaper-based Material You palette instead of the app's own. */
    val dynamicColor: Boolean = false,
    /** The generator opens with whatever the user picked last time. */
    val generatorOptions: PasswordOptions = PasswordOptions(),
)
