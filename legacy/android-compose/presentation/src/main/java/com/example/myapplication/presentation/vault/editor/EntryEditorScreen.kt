package com.example.myapplication.presentation.vault.editor

import androidx.activity.compose.BackHandler
import androidx.compose.animation.AnimatedVisibility
import androidx.compose.animation.core.tween
import androidx.compose.animation.expandVertically
import androidx.compose.animation.fadeIn
import androidx.compose.animation.fadeOut
import androidx.compose.animation.shrinkVertically
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.consumeWindowInsets
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.imePadding
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.layout.widthIn
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.text.KeyboardOptions
import androidx.compose.foundation.verticalScroll
import androidx.compose.material3.AlertDialog
import androidx.compose.material3.FilledTonalButton
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.OutlinedTextField
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Text
import androidx.compose.material3.TextButton
import androidx.compose.material3.TopAppBar
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.saveable.rememberSaveable
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.text.input.ImeAction
import androidx.compose.ui.text.input.KeyboardCapitalization
import androidx.compose.ui.text.input.KeyboardType
import androidx.compose.ui.unit.dp
import androidx.hilt.lifecycle.viewmodel.compose.hiltViewModel
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import com.example.myapplication.designsystem.component.PasswordField
import com.example.myapplication.designsystem.component.ReadableWidth
import com.example.myapplication.designsystem.component.surfaceTopAppBarColors
import com.example.myapplication.designsystem.icon.BovedaIcons
import com.example.myapplication.designsystem.theme.BovedaMotion
import com.example.myapplication.presentation.R
import com.example.myapplication.presentation.common.FormMessage
import com.example.myapplication.presentation.common.PasswordStrengthIndicator
import com.example.myapplication.presentation.generator.GeneratorSheet

@Composable
fun EntryEditorScreen(
    onClose: () -> Unit,
    onSaved: (id: String, wasNew: Boolean) -> Unit,
    viewModel: EntryEditorViewModel = hiltViewModel(),
) {
    val state by viewModel.uiState.collectAsStateWithLifecycle()
    var showGenerator by rememberSaveable { mutableStateOf(false) }
    var confirmDiscard by rememberSaveable { mutableStateOf(false) }

    LaunchedEffect(viewModel) {
        viewModel.events.collect { event ->
            when (event) {
                is EntryEditorEvent.Saved -> onSaved(event.id, event.wasNew)
                EntryEditorEvent.Gone -> onClose()
            }
        }
    }
    val requestClose = { if (state.hasChanges) confirmDiscard = true else onClose() }
    BackHandler(enabled = state.hasChanges) { confirmDiscard = true }

    Scaffold(
        topBar = {
            TopAppBar(
                title = { Text(stringResource(if (state.isNew) R.string.editor_new_title else R.string.editor_edit_title)) },
                navigationIcon = {
                    IconButton(onClick = requestClose) {
                        Icon(painterResource(BovedaIcons.Close), contentDescription = stringResource(R.string.editor_close))
                    }
                },
                actions = {
                    TextButton(onClick = viewModel::save, enabled = state.canSave) {
                        Text(stringResource(R.string.editor_save))
                    }
                },
                colors = surfaceTopAppBarColors(),
            )
        },
    ) { padding ->
        Box(
            Modifier
                .fillMaxSize()
                .padding(padding)
                .consumeWindowInsets(padding)
                .imePadding(),
            contentAlignment = Alignment.TopCenter,
        ) {
            Column(
                modifier = Modifier
                    .widthIn(max = ReadableWidth)
                    .fillMaxWidth()
                    .verticalScroll(rememberScrollState())
                    .padding(horizontal = 16.dp, vertical = 8.dp),
                verticalArrangement = Arrangement.spacedBy(12.dp),
            ) {
                val draft = state.draft
                OutlinedTextField(
                    value = draft.title,
                    onValueChange = viewModel::onTitleChange,
                    label = { Text(stringResource(R.string.editor_name)) },
                    placeholder = { Text(stringResource(R.string.editor_name_placeholder)) },
                    singleLine = true,
                    enabled = !state.isLoading,
                    keyboardOptions = KeyboardOptions(capitalization = KeyboardCapitalization.Sentences, imeAction = ImeAction.Next),
                    modifier = Modifier.fillMaxWidth(),
                )
                OutlinedTextField(
                    value = draft.username,
                    onValueChange = viewModel::onUsernameChange,
                    label = { Text(stringResource(R.string.editor_username)) },
                    singleLine = true,
                    enabled = !state.isLoading,
                    keyboardOptions = KeyboardOptions(
                        keyboardType = KeyboardType.Email,
                        autoCorrectEnabled = false,
                        imeAction = ImeAction.Next,
                    ),
                    modifier = Modifier.fillMaxWidth(),
                )
                Column {
                    PasswordField(
                        value = draft.password,
                        onValueChange = viewModel::onPasswordChange,
                        label = stringResource(R.string.editor_password),
                        enabled = !state.isLoading,
                        imeAction = ImeAction.Next,
                    )
                    AnimatedVisibility(
                        visible = draft.password.isNotEmpty(),
                        enter = expandVertically(tween(BovedaMotion.MEDIUM, easing = BovedaMotion.EmphasizedDecelerate)) + fadeIn(),
                        exit = shrinkVertically(tween(BovedaMotion.SHORT)) + fadeOut(tween(100)),
                    ) {
                        PasswordStrengthIndicator(state.strength, Modifier.fillMaxWidth().padding(top = 8.dp))
                    }
                    Spacer(Modifier.size(8.dp))
                    FilledTonalButton(onClick = { showGenerator = true }, enabled = !state.isLoading) {
                        Icon(painterResource(BovedaIcons.Password), contentDescription = null, modifier = Modifier.size(18.dp))
                        Spacer(Modifier.width(8.dp))
                        Text(stringResource(R.string.editor_generate))
                    }
                }
                OutlinedTextField(
                    value = draft.url,
                    onValueChange = viewModel::onUrlChange,
                    label = { Text(stringResource(R.string.editor_website)) },
                    placeholder = { Text(stringResource(R.string.editor_website_placeholder)) },
                    singleLine = true,
                    enabled = !state.isLoading,
                    keyboardOptions = KeyboardOptions(
                        keyboardType = KeyboardType.Uri,
                        autoCorrectEnabled = false,
                        imeAction = ImeAction.Next,
                    ),
                    modifier = Modifier.fillMaxWidth(),
                )
                OutlinedTextField(
                    value = draft.notes,
                    onValueChange = viewModel::onNotesChange,
                    label = { Text(stringResource(R.string.editor_notes)) },
                    minLines = 3,
                    enabled = !state.isLoading,
                    keyboardOptions = KeyboardOptions(capitalization = KeyboardCapitalization.Sentences),
                    modifier = Modifier.fillMaxWidth(),
                )
                FormMessage(state.error, color = MaterialTheme.colorScheme.error, topPadding = 0.dp)
            }
        }
    }

    if (showGenerator) {
        GeneratorSheet(
            onUse = { password ->
                viewModel.onPasswordChange(password)
                showGenerator = false
            },
            onDismiss = { showGenerator = false },
        )
    }

    if (confirmDiscard) {
        AlertDialog(
            onDismissRequest = { confirmDiscard = false },
            title = { Text(stringResource(R.string.editor_discard_title)) },
            text = { Text(stringResource(R.string.editor_discard_body)) },
            confirmButton = {
                TextButton(onClick = {
                    confirmDiscard = false
                    onClose()
                }) { Text(stringResource(R.string.editor_discard)) }
            },
            dismissButton = {
                TextButton(onClick = { confirmDiscard = false }) { Text(stringResource(R.string.editor_keep_editing)) }
            },
        )
    }
}
