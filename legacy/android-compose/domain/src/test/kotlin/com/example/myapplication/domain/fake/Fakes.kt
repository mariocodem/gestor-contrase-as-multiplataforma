package com.example.myapplication.domain.fake

import com.example.myapplication.domain.error.AppError
import com.example.myapplication.domain.error.AppException
import com.example.myapplication.domain.model.User
import com.example.myapplication.domain.model.VaultEntry
import com.example.myapplication.domain.model.VaultStatus
import com.example.myapplication.domain.repository.AuthRepository
import com.example.myapplication.domain.repository.VaultRepository
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.combine

class FakeAuthRepository(user: User? = null) : AuthRepository {
    val user = MutableStateFlow(user)
    override val currentUser: Flow<User?> = this.user

    override suspend fun signIn(email: String, password: String) {
        user.value = User(id = "uid-$email", email = email)
    }

    override suspend fun register(email: String, password: String) = signIn(email, password)

    override suspend fun sendPasswordReset(email: String) = Unit

    override fun signOut() {
        user.value = null
    }
}

class FakeVaultRepository(
    private val masterPassword: String = "correct horse battery",
) : VaultRepository {
    val status = MutableStateFlow<VaultStatus>(VaultStatus.Missing)
    val entries = MutableStateFlow<List<VaultEntry>>(emptyList())
    private val unlocked = MutableStateFlow<String?>(null)
    var createdWith: String? = null
    private var nextId = 1

    override fun observeStatus(userId: String): Flow<VaultStatus> = status

    override val unlockedUserId: StateFlow<String?> = unlocked

    override suspend fun create(userId: String, masterPassword: CharArray) {
        createdWith = String(masterPassword)
        unlocked.value = userId
    }

    override suspend fun unlock(userId: String, masterPassword: CharArray) {
        if (String(masterPassword) != this.masterPassword) throw AppException(AppError.WrongMasterPassword)
        unlocked.value = userId
    }

    override fun lock() {
        unlocked.value = null
    }

    override fun observeEntries(): Flow<List<VaultEntry>> =
        combine(entries, unlocked) { all, id -> if (id == null) emptyList() else all }

    override suspend fun save(entry: VaultEntry): VaultEntry {
        val saved = if (entry.isNew) entry.copy(id = "e${nextId++}") else entry
        entries.value = entries.value.filterNot { it.id == saved.id } + saved
        return saved
    }

    override suspend fun delete(id: String) {
        entries.value = entries.value.filterNot { it.id == id }
    }
}
