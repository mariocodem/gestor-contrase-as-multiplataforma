package com.example.myapplication.presentation.generator

import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.navigationBarsPadding
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.widthIn
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.verticalScroll
import androidx.compose.material3.Button
import androidx.compose.material3.Icon
import androidx.compose.material3.ModalBottomSheet
import androidx.compose.material3.OutlinedButton
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Scaffold
import androidx.compose.material3.SnackbarHost
import androidx.compose.material3.Text
import androidx.compose.material3.TopAppBar
import androidx.compose.material3.rememberModalBottomSheetState
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.unit.dp
import androidx.hilt.lifecycle.viewmodel.compose.hiltViewModel
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import com.example.myapplication.designsystem.component.CopyButtonContent
import com.example.myapplication.designsystem.component.ReadableWidth
import com.example.myapplication.designsystem.component.ShellPanel
import com.example.myapplication.designsystem.component.rememberCopyConfirmation
import com.example.myapplication.designsystem.component.shellTopAppBarColors
import com.example.myapplication.designsystem.icon.BovedaIcons
import com.example.myapplication.presentation.R
import com.example.myapplication.presentation.common.UiText
import com.example.myapplication.presentation.navigation.LocalSnackbarHostState

/** The Generator tab: make a password and copy it, e.g. for a sign-up form in another app. */
@Composable
fun GeneratorScreen(showMessage: (UiText) -> Unit, viewModel: GeneratorViewModel = hiltViewModel()) {
    val state by viewModel.uiState.collectAsStateWithLifecycle()
    LaunchedEffect(viewModel) { viewModel.messages.collect(showMessage) }
    val copied = rememberCopyConfirmation()

    Scaffold(
        topBar = {
            ShellPanel(contentWidth = ReadableWidth) {
                TopAppBar(title = { Text(stringResource(R.string.generator_title)) }, colors = shellTopAppBarColors())
            }
        },
        snackbarHost = { SnackbarHost(LocalSnackbarHostState.current) },
    ) { padding ->
        Box(Modifier.fillMaxSize().padding(padding), contentAlignment = Alignment.TopCenter) {
            GeneratorPanel(
                state = state,
                viewModel = viewModel,
                modifier = Modifier
                    .widthIn(max = ReadableWidth)
                    .fillMaxWidth()
                    .verticalScroll(rememberScrollState())
                    .padding(16.dp),
            ) {
                Button(
                    onClick = {
                        viewModel.copy()
                        copied.confirm()
                    },
                    modifier = Modifier.weight(1f).height(52.dp),
                ) {
                    CopyButtonContent(
                        copied = copied.isShowing,
                        label = stringResource(R.string.generator_copy),
                        copiedLabel = stringResource(R.string.generator_copied),
                    )
                }
                RegenerateButton(viewModel::regenerate)
            }
        }
    }
}

/** The generator inside the entry editor: same controls, and the result goes into the entry. */
@Composable
fun GeneratorSheet(onUse: (String) -> Unit, onDismiss: () -> Unit, viewModel: GeneratorViewModel = hiltViewModel()) {
    val state by viewModel.uiState.collectAsStateWithLifecycle()
    ModalBottomSheet(
        onDismissRequest = onDismiss,
        sheetState = rememberModalBottomSheetState(skipPartiallyExpanded = true),
    ) {
        Text(
            stringResource(R.string.generator_sheet_title),
            style = MaterialTheme.typography.titleLarge,
            modifier = Modifier.padding(horizontal = 24.dp).padding(bottom = 16.dp),
        )
        GeneratorPanel(
            state = state,
            viewModel = viewModel,
            modifier = Modifier
                .verticalScroll(rememberScrollState())
                .padding(horizontal = 24.dp)
                .padding(bottom = 24.dp)
                .navigationBarsPadding(),
        ) {
            Button(
                onClick = { state.password?.let { onUse(it.value) } },
                modifier = Modifier.weight(1f).height(52.dp),
            ) {
                Text(stringResource(R.string.generator_use))
            }
            RegenerateButton(viewModel::regenerate)
        }
    }
}

@Composable
private fun RegenerateButton(onClick: () -> Unit) {
    OutlinedButton(onClick = onClick, modifier = Modifier.height(52.dp)) {
        Icon(painterResource(BovedaIcons.Refresh), contentDescription = stringResource(R.string.generator_regenerate))
    }
}
