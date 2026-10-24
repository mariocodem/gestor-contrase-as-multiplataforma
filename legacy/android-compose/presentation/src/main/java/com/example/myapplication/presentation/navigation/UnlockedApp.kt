package com.example.myapplication.presentation.navigation

import androidx.compose.animation.AnimatedContentTransitionScope
import androidx.compose.animation.EnterTransition
import androidx.compose.animation.ExitTransition
import androidx.compose.animation.animateColorAsState
import androidx.compose.animation.SharedTransitionLayout
import androidx.compose.animation.core.tween
import androidx.compose.animation.fadeIn
import androidx.compose.animation.fadeOut
import androidx.compose.animation.scaleIn
import androidx.compose.animation.slideInHorizontally
import androidx.compose.animation.slideOutHorizontally
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.WindowInsets
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.statusBars
import androidx.compose.foundation.layout.windowInsetsTopHeight
import androidx.compose.material3.Icon
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.NavigationBarItemDefaults
import androidx.compose.material3.NavigationRailItemDefaults
import androidx.compose.material3.SnackbarHostState
import androidx.compose.material3.Text
import androidx.compose.material3.adaptive.currentWindowAdaptiveInfo
import androidx.compose.material3.adaptive.navigationsuite.NavigationSuiteDefaults
import androidx.compose.material3.adaptive.navigationsuite.NavigationSuiteScaffold
import androidx.compose.material3.adaptive.navigationsuite.NavigationSuiteScaffoldDefaults
import androidx.compose.material3.adaptive.navigationsuite.NavigationSuiteScaffoldValue
import androidx.compose.material3.adaptive.navigationsuite.NavigationSuiteType
import androidx.compose.material3.adaptive.navigationsuite.rememberNavigationSuiteScaffoldState
import androidx.compose.runtime.Composable
import androidx.compose.runtime.CompositionLocalProvider
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.remember
import androidx.compose.runtime.rememberCoroutineScope
import androidx.compose.runtime.staticCompositionLocalOf
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.drawBehind
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.res.stringResource
import androidx.navigation.NavBackStackEntry
import androidx.navigation.NavController
import androidx.navigation.NavDestination.Companion.hasRoute
import androidx.navigation.NavDestination.Companion.hierarchy
import androidx.navigation.NavGraph.Companion.findStartDestination
import androidx.navigation.compose.NavHost
import androidx.navigation.compose.composable
import androidx.navigation.compose.currentBackStackEntryAsState
import androidx.navigation.compose.rememberNavController
import com.example.myapplication.designsystem.theme.BovedaMotion
import com.example.myapplication.designsystem.theme.BovedaTheme
import com.example.myapplication.domain.model.User
import com.example.myapplication.presentation.R
import com.example.myapplication.presentation.common.SystemBarIcons
import com.example.myapplication.presentation.common.UiText
import com.example.myapplication.presentation.generator.GeneratorScreen
import com.example.myapplication.presentation.settings.SettingsScreen
import com.example.myapplication.presentation.vault.detail.EntryDetailScreen
import com.example.myapplication.presentation.vault.editor.EntryEditorScreen
import com.example.myapplication.presentation.vault.list.VaultListScreen
import kotlinx.coroutines.launch

/** One snackbar host for the whole unlocked app, so a message survives navigating back. */
val LocalSnackbarHostState = staticCompositionLocalOf<SnackbarHostState> { error("No SnackbarHostState provided") }

/**
 * The unlocked part of the app: a navigation bar on phones, a rail on wider windows, and the
 * entry detail and editor pushed on top of the vault list.
 */
@Composable
fun UnlockedApp(user: User) {
    val navController = rememberNavController()
    val snackbarHostState = remember { SnackbarHostState() }
    val scope = rememberCoroutineScope()
    val resources = LocalContext.current.resources
    val showMessage: (UiText) -> Unit = { message ->
        scope.launch {
            snackbarHostState.currentSnackbarData?.dismiss()
            snackbarHostState.showSnackbar(message.resolve(resources))
        }
    }

    val backStackEntry by navController.currentBackStackEntryAsState()
    val destination = backStackEntry?.destination
    val topLevel = TopLevelDestination.entries.firstOrNull { top ->
        destination?.hierarchy?.any { it.hasRoute(top.route::class) } == true
    }
    // Detail and editor are reached from the vault, so the vault stays the highlighted section.
    val section = topLevel ?: TopLevelDestination.VAULT
    @Suppress("DEPRECATION") // Keeps the classic bar/rail pair instead of the expressive short bar.
    val layoutType = NavigationSuiteScaffoldDefaults.calculateFromAdaptiveInfo(currentWindowAdaptiveInfo())
    // On phones the bar gives pushed screens the whole height, sliding away as the entry slides
    // in; wider windows keep the rail.
    val hideBar = destination != null && topLevel == null && layoutType == NavigationSuiteType.NavigationBar
    val suiteState = rememberNavigationSuiteScaffoldState(
        if (hideBar) NavigationSuiteScaffoldValue.Hidden else NavigationSuiteScaffoldValue.Visible,
    )
    LaunchedEffect(hideBar) {
        // snapTo rather than hide()/show(): the scaffold then slides the bar on its own spring
        // straight away, where show() would first wait out an internal animation.
        suiteState.snapTo(if (hideBar) NavigationSuiteScaffoldValue.Hidden else NavigationSuiteScaffoldValue.Visible)
    }

    val colors = BovedaTheme.colors
    val surface = MaterialTheme.colorScheme.surface
    val statusBackground = if (topLevel != null) colors.shell else surface
    val statusBand by animateColorAsState(statusBackground, tween(BovedaMotion.MEDIUM), label = "status-band")
    SystemBarIcons(
        statusBarBackground = statusBackground,
        navigationBarBackground = if (layoutType == NavigationSuiteType.NavigationBar && !hideBar) colors.shell else surface,
    )
    val itemColors = NavigationSuiteDefaults.itemColors(
        navigationBarItemColors = NavigationBarItemDefaults.colors(
            selectedIconColor = colors.onShellIndicator,
            selectedTextColor = colors.onShell,
            indicatorColor = colors.shellIndicator,
            unselectedIconColor = colors.onShellVariant,
            unselectedTextColor = colors.onShellVariant,
        ),
        navigationRailItemColors = NavigationRailItemDefaults.colors(
            selectedIconColor = colors.onShellIndicator,
            selectedTextColor = colors.onShell,
            indicatorColor = colors.shellIndicator,
            unselectedIconColor = colors.onShellVariant,
            unselectedTextColor = colors.onShellVariant,
        ),
    )

    CompositionLocalProvider(LocalSnackbarHostState provides snackbarHostState) {
        Box {
            NavigationSuiteScaffold(
                layoutType = layoutType,
                state = suiteState,
                navigationSuiteColors = NavigationSuiteDefaults.colors(
                    navigationBarContainerColor = colors.shell,
                    navigationBarContentColor = colors.onShell,
                    navigationRailContainerColor = colors.shell,
                    navigationRailContentColor = colors.onShell,
                ),
                navigationSuiteItems = {
                    TopLevelDestination.entries.forEach { item ->
                        val selected = item == section
                        item(
                            selected = selected,
                            onClick = { navController.navigateToTopLevel(item) },
                            icon = { Icon(painterResource(if (selected) item.selectedIcon else item.icon), contentDescription = null) },
                            label = { Text(stringResource(item.label)) },
                            colors = itemColors,
                        )
                    }
                },
            ) {
                SharedTransitionLayout {
                    CompositionLocalProvider(LocalSharedTransitionScope provides this) {
                        NavHost(
                            navController = navController,
                            startDestination = VaultRoute,
                            enterTransition = { if (isBetweenTopLevel()) fadeThroughIn() else sharedAxisIn(forward = true) },
                            exitTransition = { if (isBetweenTopLevel()) fadeOut(tween(90)) else sharedAxisOut(forward = true) },
                            popEnterTransition = { if (isBetweenTopLevel()) fadeThroughIn() else sharedAxisIn(forward = false) },
                            popExitTransition = { if (isBetweenTopLevel()) fadeOut(tween(90)) else sharedAxisOut(forward = false) },
                        ) {
                            composable<VaultRoute> {
                                CompositionLocalProvider(LocalNavAnimatedVisibilityScope provides this) {
                                    VaultListScreen(
                                        onOpenEntry = { id -> navController.navigate(EntryDetailRoute(id)) },
                                        onAddEntry = { navController.navigate(EntryEditorRoute()) },
                                        showMessage = showMessage,
                                    )
                                }
                            }
                            composable<EntryDetailRoute> {
                                CompositionLocalProvider(LocalNavAnimatedVisibilityScope provides this) {
                                    EntryDetailScreen(
                                        onBack = { navController.navigateUp() },
                                        onEdit = { id -> navController.navigate(EntryEditorRoute(id)) },
                                        onDeleted = { title ->
                                            navController.popBackStack()
                                            showMessage(UiText.Res(R.string.detail_deleted, listOf(title)))
                                        },
                                        showMessage = showMessage,
                                    )
                                }
                            }
                            composable<EntryEditorRoute> {
                                EntryEditorScreen(
                                    onClose = { navController.popBackStack() },
                                    onSaved = { id, wasNew ->
                                        if (wasNew) {
                                            // Straight to the new entry, ready to copy into the sign-up form.
                                            navController.navigate(EntryDetailRoute(id)) {
                                                popUpTo<EntryEditorRoute> { inclusive = true }
                                            }
                                            showMessage(UiText.Res(R.string.editor_saved))
                                        } else {
                                            navController.popBackStack()
                                            showMessage(UiText.Res(R.string.editor_updated))
                                        }
                                    },
                                )
                            }
                            composable<GeneratorRoute> { GeneratorScreen(showMessage = showMessage) }
                            composable<SettingsRoute> { SettingsScreen(user = user, showMessage = showMessage) }
                        }
                    }
                }
            }
            // The rail is graphite all the way up; one band under the status bar, in the colour of
            // the screen showing, keeps the clock legible over a light detail or editor.
            Box(
                Modifier
                    .fillMaxWidth()
                    .windowInsetsTopHeight(WindowInsets.statusBars)
                    .drawBehind { drawRect(statusBand) },
            )
        }
    }
}

private fun NavController.navigateToTopLevel(destination: TopLevelDestination) {
    navigate(destination.route) {
        popUpTo(graph.findStartDestination().id) { saveState = true }
        launchSingleTop = true
        restoreState = true
    }
}

private fun NavBackStackEntry.isTopLevel(): Boolean =
    TopLevelDestination.entries.any { top -> destination.hasRoute(top.route::class) }

private fun AnimatedContentTransitionScope<NavBackStackEntry>.isBetweenTopLevel(): Boolean =
    initialState.isTopLevel() && targetState.isTopLevel()

// Material motion: fade-through between sections, shared X axis into and out of an entry.
private fun fadeThroughIn(): EnterTransition =
    fadeIn(tween(210, delayMillis = 90)) + scaleIn(tween(210, delayMillis = 90), initialScale = 0.96f)

private fun sharedAxisIn(forward: Boolean): EnterTransition =
    slideInHorizontally(tween(260)) { width -> if (forward) width / 8 else -width / 8 } + fadeIn(tween(160, delayMillis = 60))

private fun sharedAxisOut(forward: Boolean): ExitTransition =
    slideOutHorizontally(tween(260)) { width -> if (forward) -width / 8 else width / 8 } + fadeOut(tween(90))

