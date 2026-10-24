package com.example.myapplication.domain.repository

import com.example.myapplication.domain.model.AppSettings
import com.example.myapplication.domain.model.AutoLockTimeout
import com.example.myapplication.domain.model.PasswordOptions
import kotlinx.coroutines.flow.Flow

interface SettingsRepository {
    val settings: Flow<AppSettings>

    suspend fun setAutoLock(timeout: AutoLockTimeout)

    suspend fun setDynamicColor(enabled: Boolean)

    suspend fun setGeneratorOptions(options: PasswordOptions)
}
