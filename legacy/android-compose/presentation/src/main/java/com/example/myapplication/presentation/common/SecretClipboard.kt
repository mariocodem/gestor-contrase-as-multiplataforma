package com.example.myapplication.presentation.common

import android.content.ClipData
import android.content.ClipDescription
import android.content.ClipboardManager
import android.content.Context
import android.os.Build
import android.os.Handler
import android.os.Looper
import android.os.PersistableBundle
import androidx.annotation.StringRes
import com.example.myapplication.presentation.R
import dagger.Binds
import dagger.Module
import dagger.hilt.InstallIn
import dagger.hilt.android.qualifiers.ApplicationContext
import dagger.hilt.components.SingletonComponent
import javax.inject.Inject
import javax.inject.Singleton

/** Clipboard access behind an interface, so ViewModels copy without a Context and tests can fake it. */
interface SecretClipboard {
    /** Copies [text] marked as sensitive and wipes it after [CLEAR_AFTER_SECONDS]. */
    fun copySecret(@StringRes label: Int, text: String)

    fun copyPlain(@StringRes label: Int, text: String)

    /** Android 13+ shows its own "copied" confirmation; the app then only adds what the system doesn't say. */
    val systemConfirmsCopies: Boolean

    companion object {
        const val CLEAR_AFTER_SECONDS = 45
    }
}

/** What to show after copying a secret, without repeating the system's own confirmation. */
fun SecretClipboard.secretCopiedMessage(): UiText = UiText.Res(
    if (systemConfirmsCopies) R.string.copied_password_short else R.string.copied_password,
    listOf(SecretClipboard.CLEAR_AFTER_SECONDS),
)

@Singleton
class AndroidSecretClipboard @Inject constructor(
    @param:ApplicationContext private val context: Context,
) : SecretClipboard {
    private val handler = Handler(Looper.getMainLooper())
    private var pendingClear: Runnable? = null

    override val systemConfirmsCopies: Boolean = Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU

    override fun copySecret(label: Int, text: String) = copy(label, text, sensitive = true)

    override fun copyPlain(label: Int, text: String) = copy(label, text, sensitive = false)

    private fun copy(@StringRes label: Int, text: String, sensitive: Boolean) {
        val clipboard = context.getSystemService(ClipboardManager::class.java) ?: return
        val clip = ClipData.newPlainText(context.getString(label), text)
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
            handler.postDelayed(clear, SecretClipboard.CLEAR_AFTER_SECONDS * 1000L)
        }
    }
}

@Module
@InstallIn(SingletonComponent::class)
abstract class ClipboardModule {
    @Binds
    abstract fun bindSecretClipboard(impl: AndroidSecretClipboard): SecretClipboard
}
