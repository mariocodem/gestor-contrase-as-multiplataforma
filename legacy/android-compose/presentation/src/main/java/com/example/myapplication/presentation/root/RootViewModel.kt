package com.example.myapplication.presentation.root

import androidx.lifecycle.ViewModel
import androidx.lifecycle.ViewModelStore
import androidx.lifecycle.ViewModelStoreOwner
import androidx.lifecycle.viewModelScope
import com.example.myapplication.domain.model.AppState
import com.example.myapplication.domain.usecase.auth.SignOutUseCase
import com.example.myapplication.domain.usecase.settings.ObserveSettingsUseCase
import com.example.myapplication.domain.usecase.vault.ObserveAppStateUseCase
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.SharingStarted
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.flatMapLatest
import kotlinx.coroutines.flow.map
import kotlinx.coroutines.flow.stateIn
import kotlinx.coroutines.flow.update
import javax.inject.Inject

@HiltViewModel
class RootViewModel @Inject constructor(
    observeAppState: ObserveAppStateUseCase,
    observeSettings: ObserveSettingsUseCase,
    private val signOutUseCase: SignOutUseCase,
) : ViewModel() {
    private val retries = MutableStateFlow(0)
    private var sessionStore = ViewModelStore()

    val appState: StateFlow<AppState> = retries
        .flatMapLatest { observeAppState() }
        .stateIn(viewModelScope, SharingStarted.Eagerly, AppState.Loading)

    val dynamicColor: StateFlow<Boolean> = observeSettings()
        .map { it.dynamicColor }
        .stateIn(viewModelScope, SharingStarted.Eagerly, false)

    /**
     * Owner for the unlocked screens' ViewModels. It lives here, so it survives configuration
     * changes, and [endSession] destroys it once the vault locks: no list, detail or draft outlives the key.
     */
    val sessionViewModelStoreOwner: ViewModelStoreOwner = object : ViewModelStoreOwner {
        override val viewModelStore: ViewModelStore get() = sessionStore
    }

    fun retry() = retries.update { it + 1 }

    fun signOut() = signOutUseCase()

    /** Call once the unlocked screens have left composition, never while they're still drawn. */
    fun endSession() {
        sessionStore.clear()
        sessionStore = ViewModelStore()
    }

    override fun onCleared() = endSession()
}
