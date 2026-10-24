package com.example.myapplication.designsystem.component

import androidx.annotation.DrawableRes
import androidx.compose.animation.core.RepeatMode
import androidx.compose.animation.core.animateFloat
import androidx.compose.animation.core.infiniteRepeatable
import androidx.compose.animation.core.rememberInfiniteTransition
import androidx.compose.animation.core.tween
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.BoxWithConstraints
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.ColumnScope
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.consumeWindowInsets
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.heightIn
import androidx.compose.foundation.layout.imePadding
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.layout.widthIn
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.Icon
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.material3.TopAppBarColors
import androidx.compose.material3.TopAppBarDefaults
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.alpha
import androidx.compose.ui.draw.clip
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.semantics.clearAndSetSemantics
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.dp
import com.example.myapplication.designsystem.theme.BovedaTheme

/** Widest a single column of forms or text should get on tablets and in landscape. */
val ReadableWidth: Dp = 600.dp
val FormWidth: Dp = 440.dp

/** Scrollable, vertically centred column with a readable width, for sign-in and lock forms. */
@Composable
fun CenteredForm(contentPadding: PaddingValues, content: @Composable ColumnScope.() -> Unit) {
    BoxWithConstraints(
        Modifier
            .fillMaxSize()
            .padding(contentPadding)
            .consumeWindowInsets(contentPadding)
            .imePadding(),
    ) {
        Column(
            modifier = Modifier
                .fillMaxWidth()
                .verticalScroll(rememberScrollState())
                .heightIn(min = maxHeight)
                .padding(horizontal = 24.dp, vertical = 32.dp),
            horizontalAlignment = Alignment.CenterHorizontally,
            verticalArrangement = Arrangement.Center,
        ) {
            Column(
                modifier = Modifier.widthIn(max = FormWidth).fillMaxWidth(),
                horizontalAlignment = Alignment.CenterHorizontally,
                content = content,
            )
        }
    }
}

/** Empty and error states that say what happened and what to do next. */
@Composable
fun EmptyState(
    @DrawableRes icon: Int,
    title: String,
    body: String,
    modifier: Modifier = Modifier,
    action: (@Composable () -> Unit)? = null,
) {
    Column(
        modifier = modifier.fillMaxSize().padding(horizontal = 32.dp, vertical = 48.dp),
        verticalArrangement = Arrangement.Center,
        horizontalAlignment = Alignment.CenterHorizontally,
    ) {
        Icon(
            painterResource(icon),
            contentDescription = null,
            tint = MaterialTheme.colorScheme.onSurfaceVariant,
            modifier = Modifier.size(40.dp),
        )
        Spacer(Modifier.height(16.dp))
        Text(title, style = MaterialTheme.typography.titleMedium, textAlign = TextAlign.Center)
        Spacer(Modifier.height(6.dp))
        Text(
            body,
            style = MaterialTheme.typography.bodyMedium,
            color = MaterialTheme.colorScheme.onSurfaceVariant,
            textAlign = TextAlign.Center,
            modifier = Modifier.widthIn(max = 360.dp),
        )
        if (action != null) {
            Spacer(Modifier.height(20.dp))
            action()
        }
    }
}

/** Placeholder rows shaped like the real list while the vault decrypts. */
@Composable
fun EntryRowPlaceholders(count: Int = 6, modifier: Modifier = Modifier) {
    val pulse by rememberInfiniteTransition(label = "placeholder").animateFloat(
        initialValue = 0.55f,
        targetValue = 1f,
        animationSpec = infiniteRepeatable(tween(700), RepeatMode.Reverse),
        label = "pulse",
    )
    val tone = MaterialTheme.colorScheme.surfaceContainerHighest
    Column(modifier.alpha(pulse).clearAndSetSemantics { }) {
        repeat(count) {
            Row(
                Modifier.fillMaxWidth().height(72.dp).padding(horizontal = 16.dp),
                verticalAlignment = Alignment.CenterVertically,
            ) {
                Box(Modifier.size(40.dp).clip(RoundedCornerShape(12.dp)).background(tone))
                Spacer(Modifier.width(16.dp))
                Column(verticalArrangement = Arrangement.spacedBy(8.dp)) {
                    Box(Modifier.width(140.dp).height(12.dp).clip(RoundedCornerShape(6.dp)).background(tone))
                    Box(Modifier.width(96.dp).height(10.dp).clip(RoundedCornerShape(5.dp)).background(tone))
                }
            }
        }
    }
}

/** Group label for lists and settings: weight carries the rank, not colour. */
@Composable
fun SectionLabel(text: String, modifier: Modifier = Modifier) {
    Text(
        text = text,
        style = MaterialTheme.typography.labelLarge,
        color = MaterialTheme.colorScheme.onSurfaceVariant,
        modifier = modifier.padding(start = 16.dp, end = 16.dp, top = 24.dp, bottom = 8.dp),
    )
}

/**
 * The graphite shell behind a top-level screen's bar, edge to edge, with what it holds kept to
 * [contentWidth] and centred: on a wide window the title and the search line up with the column
 * below instead of starting at the rail.
 */
@Composable
fun ShellPanel(contentWidth: Dp, content: @Composable ColumnScope.() -> Unit) {
    Box(
        Modifier.fillMaxWidth().background(BovedaTheme.colors.shell),
        contentAlignment = Alignment.TopCenter,
    ) {
        Column(Modifier.widthIn(max = contentWidth).fillMaxWidth(), content = content)
    }
}

/** Top app bar on the graphite shell panel. */
@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun shellTopAppBarColors(): TopAppBarColors {
    val colors = BovedaTheme.colors
    return TopAppBarDefaults.topAppBarColors(
        containerColor = colors.shell,
        scrolledContainerColor = colors.shell,
        titleContentColor = colors.onShell,
        navigationIconContentColor = colors.onShell,
        actionIconContentColor = colors.onShell,
    )
}

/** Top app bar for secondary screens: plain steel, so the shell marks top-level places only. */
@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun surfaceTopAppBarColors(): TopAppBarColors = TopAppBarDefaults.topAppBarColors(
    containerColor = MaterialTheme.colorScheme.surface,
    scrolledContainerColor = MaterialTheme.colorScheme.surfaceContainer,
)
