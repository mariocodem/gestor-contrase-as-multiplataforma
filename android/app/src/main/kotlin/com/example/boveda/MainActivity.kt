package com.example.boveda

import android.content.ClipData
import android.content.ClipDescription
import android.content.ClipboardManager
import android.os.Build
import android.os.Bundle
import android.os.Handler
import android.os.Looper
import android.os.PersistableBundle
import android.view.WindowManager
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

// FlutterFragmentActivity (not FlutterActivity) because local_auth's biometric checks need one.
class MainActivity : FlutterFragmentActivity() {
    private val handler = Handler(Looper.getMainLooper())
    private var pendingClear: Runnable? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        // Keep the vault out of screenshots, screen recordings and the recent-apps preview.
        if (!BuildConfig.ALLOW_SCREENSHOTS) {
            window.setFlags(WindowManager.LayoutParams.FLAG_SECURE, WindowManager.LayoutParams.FLAG_SECURE)
        }
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "boveda/platform").setMethodCallHandler { call, result ->
            when (call.method) {
                "copy" -> {
                    copy(
                        label = call.argument<String>("label").orEmpty(),
                        text = call.argument<String>("text").orEmpty(),
                        sensitive = call.argument<Boolean>("sensitive") == true,
                        clearAfterSeconds = call.argument<Int>("clearAfterSeconds") ?: 45,
                    )
                    result.success(null)
                }
                // Android 13+ shows its own "copied" confirmation; the app then only adds what it doesn't say.
                "systemConfirmsCopies" -> result.success(Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU)
                else -> result.notImplemented()
            }
        }
    }

    private fun copy(label: String, text: String, sensitive: Boolean, clearAfterSeconds: Int) {
        val clipboard = getSystemService(ClipboardManager::class.java) ?: return
        val clip = ClipData.newPlainText(label, text)
        if (sensitive && Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            // Hidden from the clipboard preview and from keyboard suggestions.
            clip.description.extras = PersistableBundle().apply { putBoolean(ClipDescription.EXTRA_IS_SENSITIVE, true) }
        }
        clipboard.setPrimaryClip(clip)

        pendingClear?.let(handler::removeCallbacks)
        pendingClear = null
        if (sensitive) {
            val clear = Runnable {
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
                    clipboard.clearPrimaryClip()
                } else {
                    clipboard.setPrimaryClip(ClipData.newPlainText("", ""))
                }
            }
            pendingClear = clear
            handler.postDelayed(clear, clearAfterSeconds * 1000L)
        }
    }
}
