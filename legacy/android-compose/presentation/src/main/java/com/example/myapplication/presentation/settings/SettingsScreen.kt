package com.example.myapplication.presentation.settings

import android.os.Build
import androidx.activity.compose.LocalActivity
import androidx.annotation.StringRes
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.heightIn
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.layout.widthIn
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.selection.selectable
import androidx.compose.foundation.selection.selectableGroup
import androidx.compose.foundation.selection.toggleable
import androidx.compose.foundation.verticalScroll
import androidx.compose.material3.AlertDialog
import androidx.compose.material3.Icon
import androidx.compose.material3.ListItem
import androidx.compose.material3.ListItemDefaults
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.RadioButton
import androidx.compose.material3.Scaffold
import androidx.compose.material3.SnackbarHost
import androidx.compose.material3.Switch
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
import androidx.compose.ui.semantics.Role
import androidx.compose.ui.unit.dp
import androidx.fragment.app.FragmentActivity
import androidx.hilt.lifecycle.viewmodel.compose.hiltViewModel
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import com.example.myapplication.designsystem.component.ReadableWidth
import com.example.myapplication.designsystem.component.SectionLabel
import com.example.myapplication.designsystem.component.ShellPanel
import com.example.myapplication.designsystem.component.shellTopAppBarColors
import com.example.myapplication.designsystem.icon.BovedaIcons
import com.example.myapplication.domain.model.AutoLockTimeout
import com.example.myapplication.domain.model.User
import com.example.myapplication.presentation.R
import com.example.myapplication.presentation.common.UiText
import com.example.myapplication.presentation.common.authenticateWithBiometrics
import com.example.myapplication.presentation.navigation.LocalSnackbarHostState

@Composable
fun SettingsScreen(
    user: User,
    showMessage: (UiText) -> Unit,
    viewModel: SettingsViewModel = hiltViewModel<SettingsViewModel, SettingsViewModel.Factory> { it.create(user) },
) {
    val state by viewModel.uiState.collectAsStateWithLifecycle()
    LaunchedEffect(viewModel) { viewModel.messages.collect(showMessage) }
    val activity = LocalActivity.current as? FragmentActivity
    var choosingAutoLock by rememberSaveable { mutableStateOf(false) }
    val promptTitle = stringResource(R.string.settings_biometric_prompt)
    val promptCancel = stringResource(R.string.action_cancel)

    val toggleBiometric: (Boolean) -> Unit = { enable ->
        if (!enable) {
            viewModel.disableBiometric()
        } else {
            val cipher = viewModel.biometricEnrollmentCipher()
            if (activity != null && cipher != null) {
                activity.authenticateWithBiometrics(
                    title = promptTitle,
                    negativeButton = promptCancel,
                    cipher = cipher,
                    onSuccess = viewModel::onBiometricEnrolled,
                    onError = viewModel::onBiometricError,
                )
            }
        }
    }

    Scaffold(
        topBar = {
            ShellPanel(contentWidth = ReadableWidth) {
                TopAppBar(title = { Text(stringResource(R.string.settings_title)) }, colors = shellTopAppBarColors())
            }
        },
        snackbarHost = { SnackbarHost(LocalSnackbarHostState.current) },
    ) { padding ->
        Box(Modifier.fillMaxSize().padding(padding), contentAlignment = Alignment.TopCenter) {
            Column(
                Modifier
                    .widthIn(max = ReadableWidth)
                    .fillMaxWidth()
                    .verticalScroll(rememberScrollState())
                    .padding(bottom = 24.dp),
            ) {
                SectionLabel(stringResource(R.string.settings_account))
                SettingRow(
                    icon = BovedaIcons.Person,
                    title = state.email ?: "—",
                    body = stringResource(R.string.settings_signed_in),
                )
                SettingRow(
                    icon = BovedaIcons.Logout,
                    title = stringResource(R.string.action_sign_out),
                    modifier = Modifier.clickable(onClick = viewModel::signOut),
                )

                SectionLabel(stringResource(R.string.settings_security))
                val biometricUsable = state.biometricAvailable || state.biometricEnabled
                SettingRow(
                    icon = BovedaIcons.Fingerprint,
                    title = stringResource(R.string.settings_biometric),
                    body = stringResource(
                        if (biometricUsable) R.string.settings_biometric_body else R.string.settings_biometric_unavailable,
                    ),
                    modifier = Modifier.toggleable(
                        value = state.biometricEnabled,
                        enabled = biometricUsable,
                        role = Role.Switch,
                        onValueChange = toggleBiometric,
                    ),
                    trailing = { Switch(checked = state.biometricEnabled, onCheckedChange = null, enabled = biometricUsable) },
                )
                SettingRow(
                    icon = BovedaIcons.Timer,
                    title = stringResource(R.string.settings_auto_lock),
                    body = stringResource(state.autoLock.label()),
                    modifier = Modifier.clickable { choosingAutoLock = true },
                )
                SettingRow(
                    icon = BovedaIcons.Lock,
                    title = stringResource(R.string.settings_lock_now),
                    body = stringResource(R.string.settings_lock_now_body),
                    modifier = Modifier.clickable(onClick = viewModel::lockNow),
                )

                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                    SectionLabel(stringResource(R.string.settings_appearance))
                    SettingRow(
                        icon = BovedaIcons.Palette,
                        title = stringResource(R.string.settings_dynamic_color),
                        body = stringResource(R.string.settings_dynamic_color_body),
                        modifier = Modifier.toggleable(
                            value = state.dynamicColor,
                            role = Role.Switch,
                            onValueChange = viewModel::setDynamicColor,
                        ),
                        trailing = { Switch(checked = state.dynamicColor, onCheckedChange = null) },
                    )
                }

                // On the list keylines: icon in the same 24 dp slot, text on the same column.
                Row(Modifier.padding(start = 16.dp, end = 24.dp, top = 32.dp)) {
                    Box(Modifier.size(24.dp), contentAlignment = Alignment.Center) {
                        Icon(
                            painterResource(BovedaIcons.Encrypted),
                            contentDescription = null,
                            tint = MaterialTheme.colorScheme.onSurfaceVariant,
                            modifier = Modifier.size(20.dp),
                        )
                    }
                    Spacer(Modifier.width(16.dp))
                    Column {
                        Text(stringResource(R.string.settings_about), style = MaterialTheme.typography.titleSmall)
                        Text(
                            stringResource(R.string.settings_about_body),
                            style = MaterialTheme.typography.bodySmall,
                            color = MaterialTheme.colorScheme.onSurfaceVariant,
                        )
                    }
                }
            }
        }
    }

    if (choosingAutoLock) {
        AutoLockDialog(
            selected = state.autoLock,
            onSelect = {
                viewModel.setAutoLock(it)
                choosingAutoLock = false
            },
            onDismiss = { choosingAutoLock = false },
        )
    }
}

@Composable
private fun SettingRow(
    icon: Int,
    title: String,
    modifier: Modifier = Modifier,
    body: String? = null,
    trailing: (@Composable () -> Unit)? = null,
) {
    ListItem(
        headlineContent = { Text(title) },
        supportingContent = body?.let { { Text(it) } },
        leadingContent = { Icon(painterResource(icon), contentDescription = null) },
        trailingContent = trailing,
        colors = ListItemDefaults.colors(containerColor = MaterialTheme.colorScheme.surface),
        modifier = modifier.heightIn(min = 56.dp),
    )
}

@Composable
private fun AutoLockDialog(selected: AutoLockTimeout, onSelect: (AutoLockTimeout) -> Unit, onDismiss: () -> Unit) {
    AlertDialog(
        onDismissRequest = onDismiss,
        icon = { Icon(painterResource(BovedaIcons.Timer), contentDescription = null) },
        title = { Text(stringResource(R.string.settings_auto_lock)) },
        text = {
            Column(Modifier.selectableGroup()) {
                Text(
                    stringResource(R.string.auto_lock_dialog_body),
                    style = MaterialTheme.typography.bodyMedium,
                    modifier = Modifier.padding(bottom = 8.dp),
                )
                AutoLockTimeout.entries.forEach { timeout ->
                    Row(
                        verticalAlignment = Alignment.CenterVertically,
                        modifier = Modifier
                            .fillMaxWidth()
                            .heightIn(min = 48.dp)
                            .selectable(selected = timeout == selected, role = Role.RadioButton, onClick = { onSelect(timeout) }),
                    ) {
                        RadioButton(selected = timeout == selected, onClick = null)
                        Spacer(Modifier.width(16.dp))
                        Text(stringResource(timeout.label()), style = MaterialTheme.typography.bodyLarge)
                    }
                }
            }
        },
        confirmButton = { TextButton(onClick = onDismiss) { Text(stringResource(R.string.action_cancel)) } },
    )
}

@StringRes
private fun AutoLockTimeout.label(): Int = when (this) {
    AutoLockTimeout.IMMEDIATELY -> R.string.auto_lock_immediately
    AutoLockTimeout.SECONDS_30 -> R.string.auto_lock_30_seconds
    AutoLockTimeout.MINUTE_1 -> R.string.auto_lock_1_minute
    AutoLockTimeout.MINUTES_5 -> R.string.auto_lock_5_minutes
    AutoLockTimeout.MINUTES_15 -> R.string.auto_lock_15_minutes
}
