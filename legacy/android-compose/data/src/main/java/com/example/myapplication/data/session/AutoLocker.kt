package com.example.myapplication.data.session

import android.os.Handler
import android.os.Looper
import android.os.SystemClock
import com.example.myapplication.data.di.ApplicationScope
import com.example.myapplication.domain.model.AppSettings
import com.example.myapplication.domain.repository.SettingsRepository
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.flow.SharingStarted
import kotlinx.coroutines.flow.map
import kotlinx.coroutines.flow.stateIn
import javax.inject.Inject
import javax.inject.Singleton

/**
 * Drops the vault key once the app has spent the configured time in the background. The app
 * module forwards process start/stop events here.
 */
@Singleton
class AutoLocker @Inject constructor(
    private val session: VaultSession,
    settings: SettingsRepository,
    @ApplicationScope scope: CoroutineScope,
) {
    private val timeout = settings.settings
        .map { it.autoLock }
        .stateIn(scope, SharingStarted.Eagerly, AppSettings().autoLock)

    private val handler = Handler(Looper.getMainLooper())
    private val lockRunnable = Runnable { session.close() }
    private var backgroundedAt = 0L

    fun onAppBackgrounded() {
        backgroundedAt = SystemClock.elapsedRealtime()
        val delay = timeout.value.millis
        if (delay == 0L) session.close() else handler.postDelayed(lockRunnable, delay)
    }

    fun onAppForegrounded() {
        handler.removeCallbacks(lockRunnable)
        // postDelayed's clock stops while the device sleeps, so also check elapsed real time.
        val away = SystemClock.elapsedRealtime() - backgroundedAt
        if (backgroundedAt != 0L && away >= timeout.value.millis) session.close()
        backgroundedAt = 0L
    }
}
