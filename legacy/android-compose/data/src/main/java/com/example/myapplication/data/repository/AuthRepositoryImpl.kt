package com.example.myapplication.data.repository

import com.example.myapplication.data.mapper.backendCall
import com.example.myapplication.domain.model.User
import com.example.myapplication.domain.repository.AuthRepository
import com.google.firebase.auth.FirebaseAuth
import kotlinx.coroutines.channels.awaitClose
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.callbackFlow
import kotlinx.coroutines.flow.distinctUntilChanged
import kotlinx.coroutines.tasks.await
import javax.inject.Inject
import javax.inject.Singleton

@Singleton
class AuthRepositoryImpl @Inject constructor(private val auth: FirebaseAuth) : AuthRepository {

    override val currentUser: Flow<User?> = callbackFlow {
        val listener = FirebaseAuth.AuthStateListener { firebase ->
            trySend(firebase.currentUser?.let { User(id = it.uid, email = it.email) })
        }
        auth.addAuthStateListener(listener)
        awaitClose { auth.removeAuthStateListener(listener) }
    }.distinctUntilChanged()

    override suspend fun signIn(email: String, password: String) {
        backendCall { auth.signInWithEmailAndPassword(email, password).await() }
    }

    override suspend fun register(email: String, password: String) {
        backendCall { auth.createUserWithEmailAndPassword(email, password).await() }
    }

    override suspend fun sendPasswordReset(email: String) {
        backendCall { auth.sendPasswordResetEmail(email).await() }
    }

    override fun signOut() = auth.signOut()
}
