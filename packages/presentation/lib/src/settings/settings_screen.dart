import 'dart:async';

import 'package:boveda_designsystem/boveda_designsystem.dart';
import 'package:boveda_domain/boveda_domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../common/dependencies.dart';
import '../common/messages.dart';
import '../common/strings.dart';
import 'settings_cubit.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key, required this.user});

  final User user;

  @override
  Widget build(BuildContext context) => BlocProvider(
        create: (context) => SettingsCubit(context.read<Dependencies>(), user),
        child: const _SettingsContent(),
      );
}

class _SettingsContent extends StatefulWidget {
  const _SettingsContent();

  @override
  State<_SettingsContent> createState() => _SettingsContentState();
}

class _SettingsContentState extends State<_SettingsContent> {
  late final StreamSubscription<String> _messages;

  @override
  void initState() {
    super.initState();
    _messages = context.read<SettingsCubit>().messages.listen((text) {
      if (mounted) showMessage(context, text);
    });
  }

  @override
  void dispose() {
    _messages.cancel();
    super.dispose();
  }

  Future<void> _chooseAutoLock(AutoLockTimeout selected) async {
    final cubit = context.read<SettingsCubit>();
    final choice = await showDialog<AutoLockTimeout>(
      context: context,
      builder: (context) => _AutoLockDialog(selected: selected),
    );
    if (choice != null) await cubit.setAutoLock(choice);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cubit = context.read<SettingsCubit>();
    final dynamicAvailable = DynamicColorAvailability.of(context);
    return Scaffold(
      extendBody: true,
      bottomNavigationBar: const ShellDockSpacer(),
      appBar: const ShellTopBar(title: S.settingsTitle, contentWidth: readableWidth),
      body: BlocBuilder<SettingsCubit, SettingsState>(
        builder: (context, state) {
          final biometricUsable = state.biometricAvailable || state.biometricEnabled;
          return Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: readableWidth),
              child: ListView(
                padding: EdgeInsets.fromLTRB(16, 4, 16, 24 + MediaQuery.paddingOf(context).bottom),
                children: [
                  const SectionLabel(S.settingsAccount),
                  _SettingsGroup(
                    children: [
                      _AccountRow(email: state.email ?? '—'),
                      _SettingRow(icon: BovedaIcons.logout, title: S.signOut, onTap: cubit.signOut),
                    ],
                  ),
                  const SectionLabel(S.settingsSecurity),
                  _SettingsGroup(
                    children: [
                      _SettingRow(
                        icon: BovedaIcons.fingerprint,
                        title: S.settingsBiometric,
                        body: biometricUsable ? S.settingsBiometricBody : S.settingsBiometricUnavailable,
                        enabled: biometricUsable,
                        onTap: () => _toggleBiometric(!state.biometricEnabled),
                        trailing: Switch(
                          value: state.biometricEnabled,
                          onChanged: biometricUsable ? _toggleBiometric : null,
                        ),
                      ),
                      _SettingRow(
                        icon: BovedaIcons.timer,
                        title: S.settingsAutoLock,
                        body: _autoLockLabel(state.autoLock),
                        onTap: () => _chooseAutoLock(state.autoLock),
                        trailing: BovedaIcon(BovedaIcons.chevronRight, color: theme.colorScheme.onSurfaceVariant),
                      ),
                      _SettingRow(
                        icon: BovedaIcons.lock,
                        title: S.settingsLockNow,
                        body: S.settingsLockNowBody,
                        onTap: cubit.lockNow,
                      ),
                    ],
                  ),
                  const SectionLabel(S.settingsAppearance),
                  _SettingsGroup(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: BovedaSegmented<AppThemeMode>(
                          selected: state.themeMode,
                          onChanged: cubit.setThemeMode,
                          segments: const [
                            BovedaSegment(value: AppThemeMode.system, label: S.settingsThemeSystem),
                            BovedaSegment(value: AppThemeMode.light, label: S.settingsThemeLight),
                            BovedaSegment(value: AppThemeMode.dark, label: S.settingsThemeDark),
                          ],
                        ),
                      ),
                      if (dynamicAvailable)
                        _SettingRow(
                          icon: BovedaIcons.palette,
                          title: S.settingsDynamicColor,
                          body: S.settingsDynamicColorBody,
                          onTap: () => cubit.setDynamicColor(!state.dynamicColor),
                          trailing: Switch(value: state.dynamicColor, onChanged: cubit.setDynamicColor),
                        ),
                    ],
                  ),
                  // On the list keylines: icon in the same 24 dp slot, text on the same column.
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 28, 16, 0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox.square(
                          dimension: 24,
                          child: Center(
                            child: BovedaIcon(BovedaIcons.encrypted, size: 20, color: theme.colorScheme.onSurfaceVariant),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(S.settingsAbout, style: theme.textTheme.titleSmall),
                              Text(
                                S.settingsAboutBody,
                                style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _toggleBiometric(bool enable) {
    final cubit = context.read<SettingsCubit>();
    if (enable) {
      cubit.enableBiometric(BiometricPrompt(title: S.settingsBiometricPrompt, cancel: S.cancel));
    } else {
      cubit.disableBiometric();
    }
  }
}

String _autoLockLabel(AutoLockTimeout timeout) => switch (timeout) {
      AutoLockTimeout.immediately => S.autoLockImmediately,
      AutoLockTimeout.seconds30 => S.autoLock30Seconds,
      AutoLockTimeout.minute1 => S.autoLock1Minute,
      AutoLockTimeout.minutes5 => S.autoLock5Minutes,
      AutoLockTimeout.minutes15 => S.autoLock15Minutes,
    };

/// Related settings on one plate, with hairlines that start past the icon.
class _SettingsGroup extends StatelessWidget {
  const _SettingsGroup({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Plate(
        child: Column(
          children: [
            for (final (index, child) in children.indexed) ...[
              if (index > 0) const Divider(indent: 68),
              child,
            ],
          ],
        ),
      );
}

/// Who is signed in: the app's mark beside the account.
class _AccountRow extends StatelessWidget {
  const _AccountRow({required this.email});

  final String email;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return MergeSemantics(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            const _IconWell(BovedaIcons.lock),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(email, style: theme.textTheme.titleMedium, maxLines: 1, overflow: TextOverflow.ellipsis),
                  Text(
                    S.settingsSignedIn,
                    style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingRow extends StatelessWidget {
  const _SettingRow({
    required this.icon,
    required this.title,
    this.body,
    this.onTap,
    this.trailing,
    this.enabled = true,
  });

  final BovedaIconData icon;
  final String title;
  final String? body;
  final VoidCallback? onTap;
  final Widget? trailing;
  final bool enabled;

  @override
  Widget build(BuildContext context) => MergeSemantics(
        child: ListTile(
          enabled: enabled,
          leading: _IconWell(icon),
          horizontalTitleGap: 12,
          title: Text(title),
          subtitle: body == null ? null : Text(body!),
          trailing: trailing,
          onTap: onTap,
        ),
      );
}

class _IconWell extends StatelessWidget {
  const _IconWell(this.icon);

  final BovedaIconData icon;

  @override
  Widget build(BuildContext context) => DecoratedBox(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainer,
          borderRadius: BovedaShapes.small,
        ),
        child: SizedBox.square(dimension: 40, child: Center(child: BovedaIcon(icon, size: 22))),
      );
}

class _AutoLockDialog extends StatelessWidget {
  const _AutoLockDialog({required this.selected});

  final AutoLockTimeout selected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AlertDialog(
      icon: const BovedaIcon(BovedaIcons.timer),
      title: const Text(S.settingsAutoLock),
      contentPadding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
      content: RadioGroup<AutoLockTimeout>(
        groupValue: selected,
        onChanged: (value) => Navigator.pop(context, value),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(S.autoLockDialogBody, style: theme.textTheme.bodyMedium),
            ),
            for (final timeout in AutoLockTimeout.values)
              InkWell(
                onTap: () => Navigator.pop(context, timeout),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(minHeight: 48),
                  child: Row(
                    children: [
                      Radio<AutoLockTimeout>(value: timeout),
                      const SizedBox(width: 16),
                      Text(_autoLockLabel(timeout), style: theme.textTheme.bodyLarge),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
      actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text(S.cancel))],
    );
  }
}
