package com.example.myapplication.presentation

import com.example.myapplication.domain.model.AppSettings
import com.example.myapplication.domain.model.AutoLockTimeout
import com.example.myapplication.domain.model.PasswordOptions
import com.example.myapplication.domain.model.VaultEntry
import com.example.myapplication.domain.model.VaultStatus
import com.example.myapplication.domain.repository.SettingsRepository
import com.example.myapplication.domain.repository.VaultRepository
import com.example.myapplication.presentation.common.SecretClipboard
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.flowOf
import kotlinx.coroutines.test.TestDispatcher
import kotlinx.coroutines.test.UnconfinedTestDispatcher
import kotlinx.coroutines.test.resetMain
import kotlinx.coroutines.test.setMain
import org.junit.rules.TestWatcher
import org.junit.runner.Description

class MainDispatcherRule(private val dispatcher: TestDispatcher = UnconfinedTestDispatcher()) : TestWatcher() {
    override fun starting(description: Description) = Dispatchers.setMain(dispatcher)
    override fun finished(description: Description) = Dispatchers.resetMain()
}

class FakeClipboard(override val systemConfirmsCopies: Boolean = true) : SecretClipboard {
    val secrets = mutableListOf<String>()
    val plain = mutableListOf<String>()
    override fun copySecret(label: Int, text: String) { secrets += text }
    override fun copyPlain(label: Int, text: String) { plain += text }
}

class FakeSettingsRepository(initial: AppSettings = AppSettings()) : SettingsRepository {
    val state = MutableStateFlow(initial)
    var savedOptions = mutableListOf<PasswordOptions>()
    override val settings: Flow<AppSettings> = state
    override suspend fun setAutoLock(timeout: AutoLockTimeout) { state.value = state.value.copy(autoLock = timeout) }
    override suspend fun setDynamicColor(enabled: Boolean) { state.value = state.value.copy(dynamicColor = enabled) }
    override suspend fun setGeneratorOptions(options: PasswordOptions) {
        savedOptions += options
        state.value = state.value.copy(generatorOptions = options)
    }
}

/** An unlocked in-memory vault. */
class FakeVaultRepository(entries: List<VaultEntry> = emptyList()) : VaultRepository {
    val entries = MutableStateFlow(entries)
    private var nextId = 100
    override fun observeStatus(userId: String): Flow<VaultStatus> = flowOf(VaultStatus.Present)
    override val unlockedUserId: StateFlow<String?> = MutableStateFlow("u1")
    override suspend fun create(userId: String, masterPassword: CharArray) = Unit
    override suspend fun unlock(userId: String, masterPassword: CharArray) = Unit
    override fun lock() = Unit
    override fun observeEntries(): Flow<List<VaultEntry>> = entries
    override val lastKnownEntries: List<VaultEntry>? get() = entries.value
    override suspend fun save(entry: VaultEntry): VaultEntry {
        val saved = if (entry.isNew) entry.copy(id = "e${nextId++}") else entry
        entries.value = entries.value.filterNot { it.id == saved.id } + saved
        return saved
    }
    override suspend fun delete(id: String) { entries.value = entries.value.filterNot { it.id == id } }
}
