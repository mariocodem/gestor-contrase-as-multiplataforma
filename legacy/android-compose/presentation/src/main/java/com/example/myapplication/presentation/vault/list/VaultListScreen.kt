package com.example.myapplication.presentation.vault.list

import androidx.compose.animation.AnimatedContent
import androidx.compose.animation.core.tween
import androidx.compose.animation.fadeIn
import androidx.compose.animation.fadeOut
import androidx.compose.animation.togetherWith
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.widthIn
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.lazy.rememberLazyListState
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.text.KeyboardActions
import androidx.compose.foundation.text.KeyboardOptions
import androidx.compose.foundation.text.selection.LocalTextSelectionColors
import androidx.compose.foundation.text.selection.TextSelectionColors
import androidx.compose.material3.ExtendedFloatingActionButton
import androidx.compose.material3.HorizontalDivider
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.ListItem
import androidx.compose.material3.ListItemDefaults
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.OutlinedButton
import androidx.compose.material3.Scaffold
import androidx.compose.material3.SnackbarHost
import androidx.compose.material3.Text
import androidx.compose.material3.TextField
import androidx.compose.material3.TextFieldDefaults
import androidx.compose.material3.TopAppBar
import androidx.compose.runtime.Composable
import androidx.compose.runtime.CompositionLocalProvider
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.derivedStateOf
import androidx.compose.runtime.getValue
import androidx.compose.runtime.remember
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.platform.LocalFocusManager
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.res.pluralStringResource
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.text.input.ImeAction
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import androidx.hilt.lifecycle.viewmodel.compose.hiltViewModel
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import com.example.myapplication.designsystem.component.CopyIcon
import com.example.myapplication.designsystem.component.EmptyState
import com.example.myapplication.designsystem.component.EntryRowPlaceholders
import com.example.myapplication.designsystem.component.KeyCap
import com.example.myapplication.designsystem.component.ShellPanel
import com.example.myapplication.designsystem.component.rememberCopyConfirmation
import com.example.myapplication.designsystem.component.shellTopAppBarColors
import com.example.myapplication.designsystem.icon.BovedaIcons
import com.example.myapplication.designsystem.theme.BovedaMotion
import com.example.myapplication.designsystem.theme.BovedaTheme
import com.example.myapplication.presentation.R
import com.example.myapplication.presentation.common.UiText
import com.example.myapplication.presentation.common.asString
import com.example.myapplication.presentation.common.toUiText
import com.example.myapplication.presentation.navigation.LocalSnackbarHostState
import com.example.myapplication.presentation.navigation.keyCapSharedElement

private val ListWidth = 720.dp

@Composable
fun VaultListScreen(
    onOpenEntry: (String) -> Unit,
    onAddEntry: () -> Unit,
    showMessage: (UiText) -> Unit,
    viewModel: VaultListViewModel = hiltViewModel(),
) {
    val state by viewModel.uiState.collectAsStateWithLifecycle()
    LaunchedEffect(viewModel) { viewModel.messages.collect(showMessage) }
    VaultListContent(
        state = state,
        onQueryChange = viewModel::onQueryChange,
        onOpenEntry = onOpenEntry,
        onCopyPassword = viewModel::copyPassword,
        onAddEntry = onAddEntry,
        onLock = viewModel::lock,
        onRetry = viewModel::retry,
    )
}

@Composable
private fun VaultListContent(
    state: VaultListUiState,
    onQueryChange: (String) -> Unit,
    onOpenEntry: (String) -> Unit,
    onCopyPassword: (String) -> Unit,
    onAddEntry: () -> Unit,
    onLock: () -> Unit,
    onRetry: () -> Unit,
) {
    val listState = rememberLazyListState()
    val fabExpanded by remember { derivedStateOf { listState.firstVisibleItemIndex == 0 } }

    Scaffold(
        topBar = { VaultTopBar(query = state.query, totalCount = state.totalCount, onQueryChange = onQueryChange, onLock = onLock) },
        floatingActionButton = {
            ExtendedFloatingActionButton(
                text = { Text(stringResource(R.string.vault_new)) },
                icon = { Icon(painterResource(BovedaIcons.Add), contentDescription = stringResource(R.string.vault_new_description)) },
                onClick = onAddEntry,
                expanded = fabExpanded,
                containerColor = MaterialTheme.colorScheme.primaryContainer,
                contentColor = MaterialTheme.colorScheme.onPrimaryContainer,
            )
        },
        snackbarHost = { SnackbarHost(LocalSnackbarHostState.current) },
    ) { padding ->
        val contentModifier = Modifier.fillMaxSize().padding(padding)
        // Placeholders, list and empty states cross-fade; rows already on screen don't blink.
        AnimatedContent(
            targetState = state.content(),
            transitionSpec = { fadeIn(tween(BovedaMotion.MEDIUM, delayMillis = 60)) togetherWith fadeOut(tween(BovedaMotion.SHORT)) },
            label = "vault-content",
        ) { content ->
            when (content) {
                VaultContent.Loading -> EntryRowPlaceholders(modifier = contentModifier.padding(top = 8.dp))
                VaultContent.Error -> EmptyState(
                    icon = BovedaIcons.Warning,
                    title = stringResource(R.string.vault_error_title),
                    body = state.error?.toUiText()?.asString().orEmpty(),
                    modifier = contentModifier,
                    action = { OutlinedButton(onClick = onRetry) { Text(stringResource(R.string.action_retry)) } },
                )
                VaultContent.Empty -> EmptyState(
                    icon = BovedaIcons.Key,
                    title = stringResource(R.string.vault_empty_title),
                    body = stringResource(R.string.vault_empty_body),
                    modifier = contentModifier,
                )
                VaultContent.NoResults -> EmptyState(
                    icon = BovedaIcons.Search,
                    title = stringResource(R.string.vault_no_results_title),
                    body = stringResource(R.string.vault_no_results_body, state.query.trim()),
                    modifier = contentModifier,
                )
                VaultContent.Entries -> Box(Modifier.fillMaxSize(), contentAlignment = Alignment.TopCenter) {
                    LazyColumn(
                        state = listState,
                        // Room under the last row so the FAB never covers its copy button.
                        contentPadding = PaddingValues(
                            top = padding.calculateTopPadding() + 4.dp,
                            bottom = padding.calculateBottomPadding() + 96.dp,
                        ),
                        modifier = Modifier.widthIn(max = ListWidth).fillMaxSize(),
                    ) {
                        items(state.items, key = { it.id }) { item ->
                            // While searching, rows that stay slide into their new places and the
                            // rest fade, so the key you're after is easy to follow.
                            Column(
                                Modifier.animateItem(
                                    fadeInSpec = tween(BovedaMotion.MEDIUM, delayMillis = 60),
                                    placementSpec = tween(BovedaMotion.MEDIUM, easing = BovedaMotion.EmphasizedDecelerate),
                                    fadeOutSpec = tween(100),
                                ),
                            ) {
                                EntryRow(
                                    item,
                                    query = state.query,
                                    onClick = { onOpenEntry(item.id) },
                                    onCopyPassword = { onCopyPassword(item.id) },
                                )
                                HorizontalDivider(Modifier.padding(start = 72.dp), color = MaterialTheme.colorScheme.outlineVariant)
                            }
                        }
                    }
                }
            }
        }
    }
}

private enum class VaultContent { Loading, Error, Empty, NoResults, Entries }

private fun VaultListUiState.content(): VaultContent = when {
    isLoading -> VaultContent.Loading
    error != null -> VaultContent.Error
    totalCount == 0 -> VaultContent.Empty
    items.isEmpty() -> VaultContent.NoResults
    else -> VaultContent.Entries
}

/** Graphite shell: title, lock, and the search field docked beneath, all on the list's column. */
@Composable
private fun VaultTopBar(query: String, totalCount: Int, onQueryChange: (String) -> Unit, onLock: () -> Unit) {
    val colors = BovedaTheme.colors
    val focusManager = LocalFocusManager.current
    ShellPanel(contentWidth = ListWidth) {
        TopAppBar(
            title = { Text(stringResource(R.string.app_title)) },
            actions = {
                IconButton(onClick = onLock) {
                    Icon(painterResource(BovedaIcons.Lock), contentDescription = stringResource(R.string.action_lock))
                }
            },
            colors = shellTopAppBarColors(),
        )
        CompositionLocalProvider(
            LocalTextSelectionColors provides TextSelectionColors(
                handleColor = colors.shellIndicator,
                backgroundColor = colors.shellIndicator.copy(alpha = 0.35f),
            ),
        ) {
            TextField(
                value = query,
                onValueChange = onQueryChange,
                placeholder = {
                    Text(
                        if (totalCount > 0) {
                            pluralStringResource(R.plurals.vault_search_count, totalCount, totalCount)
                        } else {
                            stringResource(R.string.vault_search)
                        },
                    )
                },
                leadingIcon = { Icon(painterResource(BovedaIcons.Search), contentDescription = null) },
                trailingIcon = if (query.isNotEmpty()) {
                    {
                        IconButton(onClick = { onQueryChange("") }) {
                            Icon(painterResource(BovedaIcons.Close), contentDescription = stringResource(R.string.vault_clear_search))
                        }
                    }
                } else {
                    null
                },
                singleLine = true,
                shape = RoundedCornerShape(28.dp),
                keyboardOptions = KeyboardOptions(imeAction = ImeAction.Search, autoCorrectEnabled = false),
                keyboardActions = KeyboardActions(onSearch = { focusManager.clearFocus() }),
                colors = TextFieldDefaults.colors(
                    focusedContainerColor = colors.shellField,
                    unfocusedContainerColor = colors.shellField,
                    focusedTextColor = colors.onShell,
                    unfocusedTextColor = colors.onShell,
                    focusedPlaceholderColor = colors.onShellVariant,
                    unfocusedPlaceholderColor = colors.onShellVariant,
                    focusedLeadingIconColor = colors.onShellVariant,
                    unfocusedLeadingIconColor = colors.onShellVariant,
                    focusedTrailingIconColor = colors.onShell,
                    unfocusedTrailingIconColor = colors.onShell,
                    focusedIndicatorColor = Color.Transparent,
                    unfocusedIndicatorColor = Color.Transparent,
                    cursorColor = colors.shellIndicator,
                ),
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(start = 16.dp, end = 16.dp, bottom = 12.dp),
            )
        }
    }
}

@Composable
private fun EntryRow(item: EntryListItem, query: String, onClick: () -> Unit, onCopyPassword: () -> Unit) {
    val copied = rememberCopyConfirmation()
    val title = remember(item.title, query) { highlightMatches(item.title, query) }
    val subtitle = remember(item.subtitle, query) { highlightMatches(item.subtitle, query) }
    ListItem(
        headlineContent = { Text(title, maxLines = 1, overflow = TextOverflow.Ellipsis) },
        supportingContent = subtitle.takeIf { it.isNotEmpty() }?.let {
            { Text(it, maxLines = 1, overflow = TextOverflow.Ellipsis) }
        },
        leadingContent = { KeyCap(item.title, modifier = keyCapSharedElement(item.id)) },
        trailingContent = if (item.hasPassword) {
            {
                IconButton(
                    onClick = {
                        onCopyPassword()
                        copied.confirm()
                    },
                ) {
                    CopyIcon(copied.isShowing, contentDescription = stringResource(R.string.vault_copy_password_of, item.title))
                }
            }
        } else {
            null
        },
        colors = ListItemDefaults.colors(containerColor = MaterialTheme.colorScheme.surface),
        modifier = Modifier.clickable(onClick = onClick),
    )
}

@Preview(showSystemUi = true)
@Composable
private fun VaultListPreview() {
    BovedaTheme {
        val items = listOf(
            EntryListItem("1", "Banco Santander", "ana.garcia", true),
            EntryListItem("2", "Correo", "ana@correo.es", true),
            EntryListItem("3", "Netflix", "netflix.com", true),
        )
        CompositionLocalProvider(LocalSnackbarHostState provides remember { androidx.compose.material3.SnackbarHostState() }) {
            VaultListContent(VaultListUiState(isLoading = false, items = items, totalCount = 3), {}, {}, {}, {}, {}, {})
        }
    }
}
