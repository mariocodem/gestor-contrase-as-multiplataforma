package com.example.myapplication.data.remote

import android.util.Log
import com.example.myapplication.data.mapper.toAppException
import com.google.firebase.firestore.Blob
import com.google.firebase.firestore.DocumentSnapshot
import com.google.firebase.firestore.FieldValue
import com.google.firebase.firestore.FirebaseFirestore
import com.google.firebase.firestore.MetadataChanges
import com.google.firebase.firestore.Source
import kotlinx.coroutines.channels.awaitClose
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.callbackFlow
import kotlinx.coroutines.tasks.await
import javax.inject.Inject
import javax.inject.Singleton

/** Public parameters needed to turn the master password back into the vault key. */
class VaultMetaDto(val salt: ByteArray, val iterations: Int, val wrappedKey: ByteArray)

class EncryptedEntryDto(val id: String, val data: ByteArray)

sealed interface MetaSnapshot {
    /** A cache miss doesn't prove the vault doesn't exist; this waits for the server's answer. */
    data object Pending : MetaSnapshot
    data object Missing : MetaSnapshot
    data object Present : MetaSnapshot
    data object Incomplete : MetaSnapshot
}

/**
 * Firestore layout (everything sensitive is AES-GCM ciphertext):
 *
 * ```
 * users/{uid}                 { version, kdf, kdfIterations, salt, wrappedKey, createdAt }
 * users/{uid}/entries/{id}    { v, data }
 * ```
 *
 * Flows close with [com.example.myapplication.domain.error.AppException] on failure.
 */
@Singleton
class FirestoreVaultDataSource @Inject constructor(private val db: FirebaseFirestore) {

    private fun userDoc(uid: String) = db.collection("users").document(uid)
    private fun entriesOf(uid: String) = userDoc(uid).collection("entries")

    fun observeMeta(uid: String): Flow<MetaSnapshot> = callbackFlow {
        val registration = userDoc(uid).addSnapshotListener(MetadataChanges.INCLUDE) { snapshot, error ->
            when {
                error != null -> close(error.toAppException())
                snapshot == null -> Unit
                snapshot.exists() -> trySend(if (snapshot.toMeta() != null) MetaSnapshot.Present else MetaSnapshot.Incomplete)
                snapshot.metadata.isFromCache -> trySend(MetaSnapshot.Pending)
                else -> trySend(MetaSnapshot.Missing)
            }
        }
        awaitClose { registration.remove() }
    }

    /** Reads from the local cache first (the lock screen keeps it warm), then the server. */
    suspend fun getMeta(uid: String): VaultMetaDto? {
        val cached = runCatching { userDoc(uid).get(Source.CACHE).await() }.getOrNull()
        val snapshot = cached?.takeIf { it.exists() } ?: userDoc(uid).get().await()
        return snapshot.toMeta()
    }

    /** False when a vault already exists for [uid]; never overwrites one. */
    suspend fun createMeta(uid: String, meta: VaultMetaDto): Boolean {
        val doc = userDoc(uid)
        return db.runTransaction { transaction ->
            if (transaction.get(doc).exists()) {
                false
            } else {
                transaction.set(
                    doc,
                    mapOf(
                        "version" to 1,
                        "kdf" to "PBKDF2WithHmacSHA256",
                        "kdfIterations" to meta.iterations,
                        "salt" to Blob.fromBytes(meta.salt),
                        "wrappedKey" to Blob.fromBytes(meta.wrappedKey),
                        "createdAt" to FieldValue.serverTimestamp(),
                    ),
                )
                true
            }
        }.await()
    }

    /** Live entries; works offline from Firestore's local cache. */
    fun observeEntries(uid: String): Flow<List<EncryptedEntryDto>> = callbackFlow {
        val registration = entriesOf(uid).addSnapshotListener { snapshot, error ->
            if (error != null) {
                close(error.toAppException())
            } else if (snapshot != null) {
                trySend(snapshot.documents.mapNotNull { doc -> doc.getBlob("data")?.let { EncryptedEntryDto(doc.id, it.toBytes()) } })
            }
        }
        awaitClose { registration.remove() }
    }

    fun newEntryId(uid: String): String = entriesOf(uid).document().id

    /**
     * Not awaited on purpose: Firestore applies the write to the local cache immediately (so the
     * list updates) and syncs when the device is online.
     */
    fun putEntry(uid: String, id: String, data: ByteArray) {
        entriesOf(uid).document(id).set(mapOf("v" to 1, "data" to Blob.fromBytes(data)))
            .addOnFailureListener { Log.w(TAG, "Saving entry $id failed", it) }
    }

    fun deleteEntry(uid: String, id: String) {
        entriesOf(uid).document(id).delete()
            .addOnFailureListener { Log.w(TAG, "Deleting entry $id failed", it) }
    }

    private fun DocumentSnapshot.toMeta(): VaultMetaDto? {
        val salt = getBlob("salt")?.toBytes() ?: return null
        val wrappedKey = getBlob("wrappedKey")?.toBytes() ?: return null
        val iterations = getLong("kdfIterations")?.toInt() ?: return null
        return VaultMetaDto(salt, iterations, wrappedKey)
    }

    private companion object {
        const val TAG = "FirestoreVault"
    }
}
