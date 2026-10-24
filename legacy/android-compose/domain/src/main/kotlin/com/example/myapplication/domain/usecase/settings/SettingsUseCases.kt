package com.example.myapplication.domain.usecase.settings

import com.example.myapplication.domain.model.AppSettings
import com.example.myapplication.domain.model.AutoLockTimeout
import com.example.myapplication.domain.model.PasswordOptions
import com.example.myapplication.domain.repository.SettingsRepository
import kotlinx.coroutines.flow.Flow
import javax.inject.Inject

class ObserveSettingsUseCase @Inject constructor(private val settings: SettingsRepository) {
    operator fun invoke(): Flow<AppSettings> = settings.settings
}

class SetAutoLockTimeoutUseCase @Inject constructor(private val settings: SettingsRepository) {
    suspend operator fun invoke(timeout: AutoLockTimeout) = settings.setAutoLock(timeout)
}

class SetDynamicColorUseCase @Inject constructor(private val settings: SettingsRepository) {
    suspend operator fun invoke(enabled: Boolean) = settings.setDynamicColor(enabled)
}

class SaveGeneratorOptionsUseCase @Inject constructor(private val settings: SettingsRepository) {
    suspend operator fun invoke(options: PasswordOptions) = settings.setGeneratorOptions(options)
}
