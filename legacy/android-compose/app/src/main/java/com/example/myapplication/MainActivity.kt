package com.example.myapplication

import android.os.Bundle
import android.view.WindowManager
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import androidx.fragment.app.FragmentActivity
import com.example.myapplication.presentation.root.BovedaApp
import dagger.hilt.android.AndroidEntryPoint

// FragmentActivity (not ComponentActivity) because BiometricPrompt needs one.
@AndroidEntryPoint
class MainActivity : FragmentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        // Keep the vault out of screenshots, screen recordings and the recent-apps preview.
        if (!BuildConfig.ALLOW_SCREENSHOTS) {
            window.setFlags(WindowManager.LayoutParams.FLAG_SECURE, WindowManager.LayoutParams.FLAG_SECURE)
        }
        enableEdgeToEdge()
        setContent { BovedaApp() }
    }
}
