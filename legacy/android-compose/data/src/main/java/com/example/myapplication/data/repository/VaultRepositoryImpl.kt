package com.example.myapplication.data.repository

import com.example.myapplication.data.crypto.VaultCrypto
import com.example.myapplication.data.di.DefaultDispatcher
import com.example.myapplication.data.mapper.EntryCodec
import com.example.myapplication.data.mapper.backendCall
import com.example.myapplication.data.mapper.toAppException
import com.example.myapplication.data.remote.FirestoreVaultDataSource
import com.example.myapplication.data.remote.MetaSnapshot
import com.example.myapplication.data.remote.VaultMetaDto
import com.example.myapplication.data.session.VaultSession
import com.example.myapplication.domain.error.AppError
import com.example.myapplication.domain.error.AppException
import com.example.myapplication.domain.model.VaultEntry
import com.example.myapplication.domain.model.VaultStatus
import com.example.myapplication.domain.repository.VaultRepository
import kotlinx.coroutines.CoroutineDispatcher
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.catch
import kotlinx.coroutines.flow.flatMapLatest
import kotlinx.coroutines.flow.flowOf
import kotlinx.coroutines.flow.flowOn
import kotlinx.coroutines.flow.map
import kotlinx.coroutines.flow.onEach
import kotlinx.coroutines.flow.onStart
import kotlinx.coroutines.withContext
import java.security.GeneralSecurityException
import javax.inject.Inject
import javax.inject.Singleton

@Singleton
class VaultRepositoryImpl @Inject constructor(
    private val remote: FirestoreVaultDataSource,
    private val session: VaultSession,
    private val codec: EntryCodec,
    @param:DefaultDispatcher private val cryptoDispatcher: CoroutineDispatcher,
) : VaultRepository {

    override fun observeStatus(userId: String): Flow<VaultStatus> =
        remote.observeMeta(userId)
            .map { snapshot ->
                when (snapshot) {
                    MetaSnapshot.Pending -> VaultStatus.Loading
                    MetaSnapshot.Missing -> VaultStatus.Missing
                    MetaSnapshot.Present -> VaultStatus.Present
                    MetaSnapshot.Incomplete -> VaultStatus.Failed(AppError.VaultDataCorrupted)
                }
            }
            .catch { emit(VaultStatus.Failed(it.toAppException().error)) }

    override val unlockedUserId: StateFlow<String?> = session.userId

    override suspend fun create(userId: String, masterPassword: CharArray) {
        val salt = VaultCrypto.newSalt()
        val iterations = VaultCrypto.DEFAULT_ITERATIONS
        val (vaultKey, wrappedKey) = withContext(cryptoDispatcher) {
            val passwordKey = VaultCrypto.deriveKey(masterPassword, salt, iterations)
            val key = VaultCrypto.newVaultKey()
            key to VaultCrypto.wrapKey(passwordKey, key)
        }
        val created = backendCall { remote.createMeta(userId, VaultMetaDto(salt, iterations, wrappedKey)) }
        if (!created) throw AppException(AppError.VaultAlreadyExists)
        session.open(userId, vaultKey)
    }

    override suspend fun unlock(userId: String, masterPassword: CharArray) {
        val meta = backendCall { remote.getMeta(userId) } ?: throw AppException(AppError.VaultDataCorrupted)
        val vaultKey = withContext(cryptoDispatcher) {
            val passwordKey = VaultCrypto.deriveKey(masterPassword, meta.salt, meta.iterations)
            try {
                VaultCrypto.unwrapKey(passwordKey, meta.wrappedKey)
            } catch (e: GeneralSecurityException) {
                throw AppException(AppError.WrongMasterPassword, e)
            }
        }
        session.open(userId, vaultKey)
    }

    override fun lock() = session.close()

    override fun observeEntries(): Flow<List<VaultEntry>> = session.vault.flatMapLatest { vault ->
        if (vault == null) {
            flowOf(emptyList())
        } else {
            remote.observeEntries(vault.uid)
                .map { documents -> documents.mapNotNull { codec.decode(it, vault.key) } }
                .flowOn(cryptoDispatcher)
                .onEach { session.rememberEntries(vault, it) }
                // A screen opened mid-session (an entry tapped in the list) starts from what's already
                // decrypted instead of waiting for its own listener's first snapshot.
                .onStart { session.entriesOf(vault)?.let { emit(it) } }
        }
    }

    override val lastKnownEntries: List<VaultEntry>?
        get() = session.current?.let(session::entriesOf)

    override suspend fun save(entry: VaultEntry): VaultEntry {
        val vault = session.current ?: throw AppException(AppError.VaultLocked)
        val id = entry.id.ifEmpty { remote.newEntryId(vault.uid) }
        val saved = entry.copy(id = id, updatedAt = System.currentTimeMillis())
        val data = withContext(cryptoDispatcher) { codec.encode(saved, vault.key) }
        backendCall { remote.putEntry(vault.uid, id, data) }
        return saved
    }

    override suspend fun delete(id: String) {
        val vault = session.current ?: throw AppException(AppError.VaultLocked)
        backendCall { remote.deleteEntry(vault.uid, id) }
    }
}
