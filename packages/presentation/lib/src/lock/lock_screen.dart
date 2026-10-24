import 'package:boveda_designsystem/boveda_designsystem.dart';
import 'package:boveda_domain/boveda_domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../common/dependencies.dart';
import '../common/form_message.dart';
import '../common/messages.dart';
import '../common/strength_text.dart';
import '../common/strings.dart';
import 'lock_cubit.dart';

/// Creates the vault when [isSetup], otherwise unlocks it. [opening] is set while the screen leaves
/// because the vault opened, so the emblem's shackle lifts; [arrivedFromUnlocked] makes it close
/// on arrival, after a lock.
class LockScreen extends StatelessWidget {
  const LockScreen({
    super.key,
    required this.user,
    required this.isSetup,
    required this.onSignOut,
    this.opening = false,
    this.arrivedFromUnlocked = false,
  });

  final User user;
  final bool isSetup;
  final VoidCallback onSignOut;
  final bool opening;
  final bool arrivedFromUnlocked;

  @override
  Widget build(BuildContext context) => BlocProvider(
        create: (context) => LockCubit(context.read<Dependencies>(), user),
        child: _LockContent(this),
      );
}

class _LockContent extends StatefulWidget {
  const _LockContent(this.screen);

  final LockScreen screen;

  @override
  State<_LockContent> createState() => _LockContentState();
}

class _LockContentState extends State<_LockContent> {
  final _passwordFocus = FocusNode();

  LockScreen get _screen => widget.screen;

  @override
  void initState() {
    super.initState();
    final cubit = context.read<LockCubit>();
    // Offer the fingerprint straight away when it's set up; otherwise the keyboard.
    cubit.biometricsKnown.then((_) {
      if (!mounted) return;
      if (!_screen.isSetup && cubit.state.biometricEnabled) {
        _promptBiometrics();
      } else {
        _passwordFocus.requestFocus();
      }
    });
  }

  void _promptBiometrics() => context
      .read<LockCubit>()
      .unlockWithBiometrics(const BiometricPrompt(title: S.lockBiometricPrompt, cancel: S.cancel));

  void _submit() => context.read<LockCubit>().submit(isSetup: _screen.isSetup);

  @override
  void dispose() {
    _passwordFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cubit = context.read<LockCubit>();
    final isSetup = _screen.isSetup;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: systemBarsOver(theme.colorScheme.surface, theme.colorScheme.surface),
      child: Scaffold(
        body: BlocBuilder<LockCubit, LockUiState>(
          builder: (context, state) {
            // The cubit resets as soon as the key is accepted; while this screen fades out over the
            // opening vault it keeps showing the work it just finished instead of flicking back to idle.
            final working = state.isWorking || _screen.opening;
            return CenteredForm(
              children: [
                LockEmblem(locked: !_screen.opening, rejections: state.rejections, startOpen: _screen.arrivedFromUnlocked),
                const SizedBox(height: 24),
                Semantics(
                  header: true,
                  child: Text(
                    isSetup ? S.lockTitleSetup : S.lockTitleLocked,
                    style: theme.textTheme.headlineSmall,
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  isSetup ? S.lockBodySetup : S.lockBodyLocked,
                  style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                  textAlign: TextAlign.center,
                ),
                if (isSetup) ...[const SizedBox(height: 16), const _RecoveryWarning()],
                const SizedBox(height: 24),
                PasswordField(
                  value: state.password,
                  onChanged: cubit.onPasswordChange,
                  label: S.lockMasterPassword,
                  showLabel: S.showPassword,
                  hideLabel: S.hidePassword,
                  enabled: !working,
                  focusNode: _passwordFocus,
                  textInputAction: isSetup ? TextInputAction.next : TextInputAction.done,
                  onSubmitted: isSetup ? null : _submit,
                  autofillHints: const [AutofillHints.password],
                ),
                if (isSetup) ...[
                  AnimatedSize(
                    duration: BovedaMotion.of(context, BovedaMotion.medium),
                    curve: BovedaMotion.emphasizedDecelerate,
                    child: state.password.isEmpty
                        ? const SizedBox(width: double.infinity)
                        : Padding(
                            padding: const EdgeInsets.only(top: 4, bottom: 8),
                            child: SizedBox(width: double.infinity, child: PasswordStrengthIndicator(strength: state.strength)),
                          ),
                  ),
                  const SizedBox(height: 8),
                  PasswordField(
                    value: state.confirmation,
                    onChanged: cubit.onConfirmationChange,
                    label: S.lockRepeatMasterPassword,
                    showLabel: S.showPassword,
                    hideLabel: S.hidePassword,
                    enabled: !working,
                    onSubmitted: _submit,
                  ),
                ],
                FormMessage(text: state.error, color: theme.colorScheme.error),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: FilledButton(
                    onPressed: working ? null : _submit,
                    child: AnimatedSwitcher(
                      duration: BovedaMotion.of(context, BovedaMotion.short),
                      child: working
                          ? Row(
                              key: const ValueKey('busy'),
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const SizedBox.square(dimension: 20, child: CircularProgressIndicator(strokeWidth: 2)),
                                const SizedBox(width: 12),
                                Text(isSetup ? S.lockCreating : S.lockUnlocking),
                              ],
                            )
                          : Text(isSetup ? S.lockCreate : S.lockUnlock, key: const ValueKey('idle')),
                    ),
                  ),
                ),
                if (!isSetup && state.biometricEnabled) ...[
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: OutlinedButton.icon(
                      onPressed: working ? null : _promptBiometrics,
                      icon: const BovedaIcon(BovedaIcons.fingerprint),
                      label: Text(S.lockUseBiometrics),
                    ),
                  ),
                ],
                const SizedBox(height: 24),
                if (_screen.user.email != null)
                  Text(
                    S.lockSignedInAs(_screen.user.email!),
                    style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                  ),
                TextButton(onPressed: working ? null : _screen.onSignOut, child: const Text(S.signOut)),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _RecoveryWarning extends StatelessWidget {
  const _RecoveryWarning();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: theme.colorScheme.surfaceContainerHigh,
      shape: const RoundedRectangleBorder(borderRadius: BovedaShapes.medium),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            BovedaIcon(BovedaIcons.warning, size: 20, color: theme.colorScheme.error),
            const SizedBox(width: 12),
            Expanded(child: Text(S.lockWarning, style: theme.textTheme.bodyMedium)),
          ],
        ),
      ),
    );
  }
}
