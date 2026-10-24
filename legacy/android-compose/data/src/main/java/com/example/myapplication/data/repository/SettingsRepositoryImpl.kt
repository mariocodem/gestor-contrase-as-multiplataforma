package com.example.myapplication.data.repository

import androidx.datastore.core.DataStore
import androidx.datastore.preferences.core.Preferences
import androidx.datastore.preferences.core.booleanPreferencesKey
import androidx.datastore.preferences.core.edit
import androidx.datastore.preferences.core.emptyPreferences
import androidx.datastore.preferences.core.intPreferencesKey
import androidx.datastore.preferences.core.stringPreferencesKey
import com.example.myapplication.domain.model.AppSettings
import com.example.myapplication.domain.model.AutoLockTimeout
import com.example.myapplication.domain.model.PasswordOptions
import com.example.myapplication.domain.repository.SettingsRepository
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.catch
import kotlinx.coroutines.flow.distinctUntilChanged
import kotlinx.coroutines.flow.map
import java.io.IOException
import javax.inject.Inject
import javax.inject.Singleton

/** Plain preferences: nothing here is secret, so it isn't encrypted. */
@Singleton
class SettingsRepositoryImpl @Inject constructor(
    private val dataStore: DataStore<Preferences>,
) : SettingsRepository {

    override val settings: Flow<AppSettings> = dataStore.data
        .catch { if (it is IOException) emit(emptyPreferences()) else throw it }
        .map { it.toSettings() }
        .distinctUntilChanged()

    override suspend fun setAutoLock(timeout: AutoLockTimeout) {
        dataStore.edit { it[AUTO_LOCK] = timeout.name }
    }

    override suspend fun setDynamicColor(enabled: Boolean) {
        dataStore.edit { it[DYNAMIC_COLOR] = enabled }
    }

    override suspend fun setGeneratorOptions(options: PasswordOptions) {
        dataStore.edit {
            it[GEN_LENGTH] = options.length
            it[GEN_UPPERCASE] = options.uppercase
            it[GEN_LOWERCASE] = options.lowercase
            it[GEN_DIGITS] = options.digits
            it[GEN_SYMBOLS] = options.symbols
            it[GEN_AVOID_AMBIGUOUS] = options.avoidAmbiguous
        }
    }

    private fun Preferences.toSettings(): AppSettings {
        val defaults = AppSettings()
        val generator = defaults.generatorOptions
        return AppSettings(
            autoLock = this[AUTO_LOCK]?.let { name -> AutoLockTimeout.entries.find { it.name == name } }
                ?: defaults.autoLock,
            dynamicColor = this[DYNAMIC_COLOR] ?: defaults.dynamicColor,
            generatorOptions = PasswordOptions(
                length = this[GEN_LENGTH] ?: generator.length,
                uppercase = this[GEN_UPPERCASE] ?: generator.uppercase,
                lowercase = this[GEN_LOWERCASE] ?: generator.lowercase,
                digits = this[GEN_DIGITS] ?: generator.digits,
                symbols = this[GEN_SYMBOLS] ?: generator.symbols,
                avoidAmbiguous = this[GEN_AVOID_AMBIGUOUS] ?: generator.avoidAmbiguous,
            ),
        )
    }

    private companion object {
        val AUTO_LOCK = stringPreferencesKey("auto_lock")
        val DYNAMIC_COLOR = booleanPreferencesKey("dynamic_color")
        val GEN_LENGTH = intPreferencesKey("generator_length")
        val GEN_UPPERCASE = booleanPreferencesKey("generator_uppercase")
        val GEN_LOWERCASE = booleanPreferencesKey("generator_lowercase")
        val GEN_DIGITS = booleanPreferencesKey("generator_digits")
        val GEN_SYMBOLS = booleanPreferencesKey("generator_symbols")
        val GEN_AVOID_AMBIGUOUS = booleanPreferencesKey("generator_avoid_ambiguous")
    }
}
