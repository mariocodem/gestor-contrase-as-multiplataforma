package com.example.myapplication.domain.repository

import com.example.myapplication.domain.model.User
import kotlinx.coroutines.flow.Flow

/** The account decides *whose* vault can be read; it never sees the master password. */
interface AuthRepository {
    /** The signed-in user, or null when signed out. */
    val currentUser: Flow<User?>

    suspend fun signIn(email: String, password: String)

    suspend fun register(email: String, password: String)

    suspend fun sendPasswordReset(email: String)

    fun signOut()
}
