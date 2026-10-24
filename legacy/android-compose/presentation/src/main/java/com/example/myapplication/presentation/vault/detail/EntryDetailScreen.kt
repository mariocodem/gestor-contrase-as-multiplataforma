package com.example.myapplication.presentation.vault.detail

import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.WindowInsets
import androidx.compose.foundation.layout.asPaddingValues
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.heightIn
import androidx.compose.foundation.layout.navigationBars
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.layout.widthIn
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.verticalScroll
import androidx.compose.material3.AlertDialog
import androidx.compose.material3.Button
import androidx.compose.material3.DropdownMenu
import androidx.compose.material3.DropdownMenuItem
import androidx.compose.material3.HorizontalDivider
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Scaffold
import androidx.compose.material3.SnackbarHost
import androidx.compose.material3.Surface
import androidx.compose.material3.Text
import androidx.compose.material3.TextButton
import androidx.compose.material3.TopAppBar
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.saveable.rememberSaveable
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.LocalConfiguration
import androidx.compose.ui.platform.LocalUriHandler
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.unit.dp
import androidx.hilt.lifecycle.viewmodel.compose.hiltViewModel
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import com.example.myapplication.designsystem.component.CopyButtonContent
import com.example.myapplication.designsystem.component.CopyIcon
import com.example.myapplication.designsystem.component.EmptyState
import com.example.myapplication.designsystem.component.KeyCap
import com.example.myapplication.designsystem.component.ReadableWidth
import com.example.myapplication.designsystem.component.SecretText
import com.example.myapplication.designsystem.component.rememberCopyConfirmation
import com.example.myapplication.designsystem.component.surfaceTopAppBarColors
import com.example.myapplication.designsystem.icon.BovedaIcons
import com.example.myapplication.designsystem.theme.BovedaTheme
import com.example.myapplication.domain.model.VaultEntry
import com.example.myapplication.presentation.R
import com.example.myapplication.presentation.common.PasswordStrengthIndicator
import com.example.myapplication.presentation.common.UiText
import com.example.myapplication.presentation.navigation.LocalSnackbarHostState
import com.example.myapplication.presentation.navigation.keyCapSharedElement
import com.example.myapplication.presentation.vault.siteHost
import com.example.myapplication.presentation.vault.withScheme
import java.text.DateFormat
import java.util.Date
import java.util.Locale

@Composable
fun EntryDetailScreen(
    onBack: () -> Unit,
    onEdit: (String) -> Unit,
    onDeleted: (String) -> Unit,
    showMessage: (UiText) -> Unit,
    viewModel: EntryDetailViewModel = hiltViewModel(),
) {
    val state by viewModel.uiState.collectAsStateWithLifecycle()
    LaunchedEffect(viewModel) {
        viewModel.events.collect { event ->
            when (event) {
                is EntryDetailEvent.Message -> showMessage(event.text)
                is EntryDetailEvent.Deleted -> onDeleted(event.title)
            }
        }
    }
    var confirmDelete by rememberSaveable { mutableStateOf(false) }
    val loaded = state as? EntryDetailUiState.Loaded
    val passwordCopied = rememberCopyConfirmation()

    Scaffold(
        topBar = {
            TopAppBar(
                title = {},
                navigationIcon = {
                    IconButton(onClick = onBack) {
                        Icon(painterResource(BovedaIcons.ArrowBack), contentDescription = stringResource(R.string.action_back))
                    }
                },
                actions = {
                    if (loaded != null) {
                        IconButton(onClick = { onEdit(loaded.entry.id) }) {
                            Icon(painterResource(BovedaIcons.Edit), contentDescription = stringResource(R.string.detail_edit))
                        }
                        OverflowMenu(onDelete = { confirmDelete = true })
                    }
                },
                colors = surfaceTopAppBarColors(),
            )
        },
        bottomBar = {
            if (loaded != null && loaded.entry.password.isNotEmpty()) {
                // The one thing people come here for, within thumb reach.
                Surface(color = MaterialTheme.colorScheme.surface) {
                    // Raw insets: the navigation bar slides away underneath while this screen
                    // arrives, and the button should ride down with it, not jump at the end.
                    Box(
                        Modifier.fillMaxWidth().padding(WindowInsets.navigationBars.asPaddingValues()),
                        contentAlignment = Alignment.Center,
                    ) {
                        Button(
                            onClick = {
                                viewModel.copyPassword()
                                passwordCopied.confirm()
                            },
                            modifier = Modifier
                                .widthIn(max = ReadableWidth)
                                .fillMaxWidth()
                                .padding(horizontal = 16.dp, vertical = 12.dp)
                                .height(56.dp),
                        ) {
                            CopyButtonContent(
                                copied = passwordCopied.isShowing,
                                label = stringResource(R.string.detail_copy_password),
                                copiedLabel = stringResource(R.string.detail_password_copied),
                                style = MaterialTheme.typography.titleMedium,
                                gap = 10.dp,
                            )
                        }
                    }
                }
            }
        },
        snackbarHost = { SnackbarHost(LocalSnackbarHostState.current) },
    ) { padding ->
        when (val current = state) {
            EntryDetailUiState.Loading -> Unit
            EntryDetailUiState.Missing -> EmptyState(
                icon = BovedaIcons.Key,
                title = stringResource(R.string.detail_missing_title),
                body = stringResource(R.string.detail_missing_body),
                modifier = Modifier.padding(padding),
                action = { TextButton(onClick = onBack) { Text(stringResource(R.string.action_back)) } },
            )
            is EntryDetailUiState.Loaded -> DetailBody(
                state = current,
                onTogglePassword = viewModel::togglePasswordVisible,
                onCopyUsername = viewModel::copyUsername,
                modifier = Modifier.padding(padding),
            )
        }
    }

    if (confirmDelete && loaded != null) {
        AlertDialog(
            onDismissRequest = { confirmDelete = false },
            icon = { Icon(painterResource(BovedaIcons.Delete), contentDescription = null) },
            title = { Text(stringResource(R.string.detail_delete_title, loaded.entry.title)) },
            text = { Text(stringResource(R.string.detail_delete_body)) },
            confirmButton = {
                TextButton(onClick = {
                    confirmDelete = false
                    viewModel.delete()
                }) { Text(stringResource(R.string.detail_delete), color = MaterialTheme.colorScheme.error) }
            },
            dismissButton = { TextButton(onClick = { confirmDelete = false }) { Text(stringResource(R.string.action_cancel)) } },
        )
    }
}

@Composable
private fun OverflowMenu(onDelete: () -> Unit) {
    var open by remember { mutableStateOf(false) }
    Box {
        IconButton(onClick = { open = true }) {
            Icon(painterResource(BovedaIcons.MoreVert), contentDescription = stringResource(R.string.action_more))
        }
        DropdownMenu(expanded = open, onDismissRequest = { open = false }) {
            DropdownMenuItem(
                text = { Text(stringResource(R.string.detail_delete)) },
                leadingIcon = { Icon(painterResource(BovedaIcons.Delete), contentDescription = null) },
                onClick = {
                    open = false
                    onDelete()
                },
            )
        }
    }
}

@Composable
private fun DetailBody(
    state: EntryDetailUiState.Loaded,
    onTogglePassword: () -> Unit,
    onCopyUsername: () -> Unit,
    modifier: Modifier = Modifier,
) {
    val entry = state.entry
    val uriHandler = LocalUriHandler.current
    val usernameCopied = rememberCopyConfirmation()
    Box(modifier.fillMaxSize(), contentAlignment = Alignment.TopCenter) {
        Column(
            Modifier
                .widthIn(max = ReadableWidth)
                .fillMaxWidth()
                .verticalScroll(rememberScrollState())
                .padding(horizontal = 16.dp)
                .padding(bottom = 24.dp),
        ) {
            Header(entry)
            Spacer(Modifier.height(20.dp))

            FieldGroup {
                if (entry.username.isNotEmpty()) {
                    FieldRow(label = stringResource(R.string.detail_username)) {
                        Text(entry.username, style = MaterialTheme.typography.bodyLarge, modifier = Modifier.weight(1f))
                        IconButton(
                            onClick = {
                                onCopyUsername()
                                usernameCopied.confirm()
                            },
                        ) {
                            CopyIcon(usernameCopied.isShowing, contentDescription = stringResource(R.string.detail_copy_username))
                        }
                    }
                    HorizontalDivider(color = MaterialTheme.colorScheme.outlineVariant)
                }
                FieldRow(label = stringResource(R.string.detail_password)) {
                    if (entry.password.isEmpty()) {
                        Text(
                            stringResource(R.string.detail_no_password),
                            style = MaterialTheme.typography.bodyLarge,
                            color = MaterialTheme.colorScheme.onSurfaceVariant,
                            modifier = Modifier.weight(1f),
                        )
                    } else {
                        SecretText(
                            value = entry.password,
                            revealed = state.passwordVisible,
                            hiddenDescription = stringResource(R.string.detail_hidden_password),
                            modifier = Modifier.weight(1f),
                        )
                        IconButton(onClick = onTogglePassword) {
                            Icon(
                                painterResource(if (state.passwordVisible) BovedaIcons.VisibilityOff else BovedaIcons.Visibility),
                                contentDescription = stringResource(
                                    if (state.passwordVisible) R.string.detail_hide_password else R.string.detail_show_password,
                                ),
                            )
                        }
                    }
                }
                if (entry.password.isNotEmpty()) {
                    PasswordStrengthIndicator(
                        state.strength,
                        Modifier.fillMaxWidth().padding(start = 16.dp, end = 16.dp, bottom = 16.dp),
                    )
                }
                if (entry.url.isNotBlank()) {
                    HorizontalDivider(color = MaterialTheme.colorScheme.outlineVariant)
                    FieldRow(label = stringResource(R.string.detail_website)) {
                        Text(entry.url, style = MaterialTheme.typography.bodyLarge, modifier = Modifier.weight(1f))
                        IconButton(onClick = { runCatching { uriHandler.openUri(withScheme(entry.url.trim())) } }) {
                            Icon(painterResource(BovedaIcons.OpenInNew), contentDescription = stringResource(R.string.detail_open_website))
                        }
                    }
                }
            }

            if (entry.notes.isNotBlank()) {
                Spacer(Modifier.height(16.dp))
                FieldGroup {
                    Column(Modifier.padding(16.dp), verticalArrangement = Arrangement.spacedBy(4.dp)) {
                        FieldLabel(stringResource(R.string.detail_notes))
                        Text(entry.notes, style = MaterialTheme.typography.bodyLarge)
                    }
                }
            }

            if (entry.updatedAt > 0) {
                // The copy is Spanish only, so the date follows Spanish conventions on a phone set to another language.
                val deviceLocale = LocalConfiguration.current.locales[0]
                val updated = remember(entry.updatedAt, deviceLocale) {
                    val locale = deviceLocale.takeIf { it.language == "es" } ?: Locale.forLanguageTag("es")
                    DateFormat.getDateTimeInstance(DateFormat.MEDIUM, DateFormat.SHORT, locale).format(Date(entry.updatedAt))
                }
                Text(
                    stringResource(R.string.detail_updated, updated),
                    style = MaterialTheme.typography.bodySmall,
                    color = MaterialTheme.colorScheme.onSurfaceVariant,
                    modifier = Modifier.padding(start = 16.dp, top = 16.dp),
                )
            }
        }
    }
}

@Composable
private fun Header(entry: VaultEntry) {
    Row(verticalAlignment = Alignment.CenterVertically, modifier = Modifier.padding(top = 4.dp)) {
        KeyCap(entry.title, size = 60.dp, modifier = keyCapSharedElement(entry.id))
        Spacer(Modifier.width(16.dp))
        Column {
            Text(entry.title, style = MaterialTheme.typography.headlineSmall)
            siteHost(entry.url)?.let {
                Text(it, style = MaterialTheme.typography.bodyMedium, color = MaterialTheme.colorScheme.onSurfaceVariant)
            }
        }
    }
}

/** One key tag: the fields of an entry, grouped on a single raised surface. */
@Composable
private fun FieldGroup(content: @Composable () -> Unit) {
    Surface(
        color = BovedaTheme.colors.plate,
        shape = MaterialTheme.shapes.large,
        modifier = Modifier.fillMaxWidth(),
    ) {
        Column { content() }
    }
}

@Composable
private fun FieldRow(label: String, content: @Composable androidx.compose.foundation.layout.RowScope.() -> Unit) {
    Column(Modifier.heightIn(min = 72.dp).padding(start = 16.dp, end = 4.dp, top = 12.dp, bottom = 8.dp)) {
        FieldLabel(label)
        Row(verticalAlignment = Alignment.CenterVertically, content = content)
    }
}

@Composable
private fun FieldLabel(text: String) {
    Text(text, style = MaterialTheme.typography.labelMedium, color = MaterialTheme.colorScheme.onSurfaceVariant)
}

