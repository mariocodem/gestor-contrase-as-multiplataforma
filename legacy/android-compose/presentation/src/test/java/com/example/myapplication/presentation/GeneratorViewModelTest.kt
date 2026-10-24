package com.example.myapplication.presentation

import app.cash.turbine.test
import com.example.myapplication.domain.generator.PasswordGenerator
import com.example.myapplication.domain.generator.PasswordStrengthEstimator
import com.example.myapplication.domain.model.AppSettings
import com.example.myapplication.domain.model.PasswordOptions
import com.example.myapplication.domain.usecase.generator.GeneratePasswordUseCase
import com.example.myapplication.domain.usecase.settings.ObserveSettingsUseCase
import com.example.myapplication.domain.usecase.settings.SaveGeneratorOptionsUseCase
import com.example.myapplication.presentation.generator.GeneratorViewModel
import kotlinx.coroutines.test.runTest
import org.junit.Assert.assertEquals
import org.junit.Assert.assertNotEquals
import org.junit.Assert.assertTrue
import org.junit.Rule
import org.junit.Test

class GeneratorViewModelTest {
    @get:Rule
    val mainDispatcherRule = MainDispatcherRule()

    private val settings = FakeSettingsRepository(AppSettings(generatorOptions = PasswordOptions(length = 12, symbols = false)))
    private val clipboard = FakeClipboard()
    // Lazy: the ViewModel must be created after the rule has installed the test Main dispatcher.
    private val viewModel by lazy {
        GeneratorViewModel(
            ObserveSettingsUseCase(settings),
            SaveGeneratorOptionsUseCase(settings),
            GeneratePasswordUseCase(PasswordGenerator(), PasswordStrengthEstimator()),
            clipboard,
        )
    }

    @Test
    fun startsFromTheRememberedOptions() {
        val state = viewModel.uiState.value

        assertEquals(PasswordOptions(length = 12, symbols = false), state.options)
        assertEquals(12, state.password?.value?.length)
        assertTrue(state.password!!.value.all { it.isLetterOrDigit() })
    }

    @Test
    fun draggingTheLengthRegeneratesLiveButSavesOnlyWhenTheDragEnds() {
        viewModel.onLengthChange(30)
        viewModel.onLengthChange(31)

        assertEquals(31, viewModel.uiState.value.password?.value?.length)
        assertTrue(settings.savedOptions.isEmpty())

        viewModel.onLengthChangeFinished()
        assertEquals(31, settings.savedOptions.single().length)
    }

    @Test
    fun theLastCharacterSetCannotBeTurnedOff() {
        viewModel.onUppercaseChange(false)
        viewModel.onDigitsChange(false)
        viewModel.onLowercaseChange(false)

        assertEquals(1, viewModel.uiState.value.options.enabledSetCount)
        assertTrue(viewModel.uiState.value.options.lowercase)
    }

    @Test
    fun regenerateKeepsTheOptionsAndChangesThePassword() {
        val before = viewModel.uiState.value

        viewModel.regenerate()

        assertEquals(before.options, viewModel.uiState.value.options)
        assertNotEquals(before.password?.value, viewModel.uiState.value.password?.value)
    }

    @Test
    fun copyPutsTheSecretOnTheClipboardAndSaysWhenItClears() = runTest {
        viewModel.messages.test {
            viewModel.copy()

            assertEquals(listOf(viewModel.uiState.value.password!!.value), clipboard.secrets)
            awaitItem()
        }
    }
}
