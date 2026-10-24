package com.example.myapplication.presentation.common

import android.content.res.Resources
import androidx.annotation.PluralsRes
import androidx.annotation.StringRes
import androidx.compose.runtime.Composable
import androidx.compose.ui.platform.LocalContext
import com.example.myapplication.domain.error.AppError

/** Text a ViewModel can produce without a Context; the UI resolves it against resources. */
sealed interface UiText {
    data class Res(@param:StringRes val id: Int, val args: List<Any> = emptyList()) : UiText
    data class Plural(@param:PluralsRes val id: Int, val count: Int) : UiText
    data class Raw(val text: String) : UiText
    data class Error(val error: AppError) : UiText

    fun resolve(resources: Resources): String = when (this) {
        is Res -> resources.getString(id, *args.map { if (it is UiText) it.resolve(resources) else it }.toTypedArray())
        is Plural -> resources.getQuantityString(id, count, count)
        is Raw -> text
        is Error -> error.toUiText().resolve(resources)
    }
}

@Composable
fun UiText.asString(): String = resolve(LocalContext.current.resources)
