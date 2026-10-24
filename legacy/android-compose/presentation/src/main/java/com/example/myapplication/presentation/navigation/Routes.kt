package com.example.myapplication.presentation.navigation

import androidx.annotation.DrawableRes
import androidx.annotation.StringRes
import com.example.myapplication.designsystem.icon.BovedaIcons
import com.example.myapplication.presentation.R
import kotlinx.serialization.Serializable

@Serializable
data object VaultRoute

@Serializable
data object GeneratorRoute

@Serializable
data object SettingsRoute

@Serializable
data class EntryDetailRoute(val id: String)

/** No id: a new entry. */
@Serializable
data class EntryEditorRoute(val id: String? = null)

/** Type-safe routes store their properties in SavedStateHandle under the property name. */
const val ENTRY_ID_ARG = "id"

enum class TopLevelDestination(
    val route: Any,
    @param:StringRes val label: Int,
    @param:DrawableRes val icon: Int,
    @param:DrawableRes val selectedIcon: Int,
) {
    VAULT(VaultRoute, R.string.nav_vault, BovedaIcons.Key, BovedaIcons.KeyFilled),
    GENERATOR(GeneratorRoute, R.string.nav_generator, BovedaIcons.Password, BovedaIcons.PasswordFilled),
    SETTINGS(SettingsRoute, R.string.nav_settings, BovedaIcons.Settings, BovedaIcons.SettingsFilled),
}
