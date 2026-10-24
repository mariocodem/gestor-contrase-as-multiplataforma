package com.example.myapplication

import android.app.Application
import androidx.lifecycle.DefaultLifecycleObserver
import androidx.lifecycle.LifecycleOwner
import androidx.lifecycle.ProcessLifecycleOwner
import com.example.myapplication.data.session.AutoLocker
import dagger.hilt.android.HiltAndroidApp
import javax.inject.Inject

@HiltAndroidApp
class PasswordManagerApplication : Application() {
    @Inject
    lateinit var autoLocker: AutoLocker

    override fun onCreate() {
        super.onCreate()
        // The whole app going to the background (not one screen) starts the auto-lock countdown.
        ProcessLifecycleOwner.get().lifecycle.addObserver(object : DefaultLifecycleObserver {
            override fun onStart(owner: LifecycleOwner) = autoLocker.onAppForegrounded()
            override fun onStop(owner: LifecycleOwner) = autoLocker.onAppBackgrounded()
        })
    }
}
