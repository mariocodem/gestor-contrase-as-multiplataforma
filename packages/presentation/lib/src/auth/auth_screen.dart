import 'package:boveda_designsystem/boveda_designsystem.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../common/dependencies.dart';
import '../common/form_message.dart';
import '../common/strings.dart';
import 'auth_cubit.dart';

class AuthScreen extends StatelessWidget {
  const AuthScreen({super.key});

  @override
  Widget build(BuildContext context) => BlocProvider(
        create: (context) => AuthCubit(context.read<Dependencies>()),
        child: const _AuthContent(),
      );
}

class _AuthContent extends StatelessWidget {
  const _AuthContent();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cubit = context.read<AuthCubit>();
    Future<void> submit() async {
      if (await cubit.submit()) TextInput.finishAutofillContext();
    }

    return VaultStage(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: BlocBuilder<AuthCubit, AuthState>(
          // Fields keep their own text: a keystroke needn't rebuild the form.
          buildWhen: (a, b) =>
              a.isRegistering != b.isRegistering ||
              a.isWorking != b.isWorking ||
              a.error != b.error ||
              a.info != b.info ||
              a.password.isEmpty != b.password.isEmpty,
          builder: (context, state) => AutofillGroup(
            child: CenteredForm(
              children: [
                VaultDial(size: 104, working: state.isWorking, child: const AppEmblem(size: 48)),
                const SizedBox(height: 20),
                Semantics(header: true, child: Text(S.appTitle, style: theme.textTheme.headlineMedium)),
                const SizedBox(height: 8),
                _ModeCrossfade(
                  child: Text(
                    state.isRegistering ? S.authSubtitleRegister : S.authSubtitleSignIn,
                    key: ValueKey(state.isRegistering),
                    style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 32),
                BovedaTextField(
                  value: state.email,
                  onChanged: cubit.onEmailChange,
                  label: S.authEmail,
                  enabled: !state.isWorking,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  autocorrect: false,
                  autofillHints: const [AutofillHints.email, AutofillHints.username],
                ),
                const SizedBox(height: 12),
                PasswordField(
                  value: state.password,
                  onChanged: cubit.onPasswordChange,
                  label: S.authPassword,
                  showLabel: S.showPassword,
                  hideLabel: S.hidePassword,
                  enabled: !state.isWorking,
                  helperText: state.isRegistering ? S.authPasswordHint : null,
                  onSubmitted: submit,
                  secretStyle: false,
                  autofillHints: [state.isRegistering ? AutofillHints.newPassword : AutofillHints.password],
                ),
                FormMessage(text: state.error, color: theme.colorScheme.error),
                FormMessage(text: state.info, color: theme.colorScheme.onSurfaceVariant),
                const SizedBox(height: 24),
                BovedaButton(
                  size: BovedaButtonSize.large,
                  fullWidth: true,
                  loading: state.isWorking,
                  onPressed: submit,
                  child: _ModeCrossfade(
                    child: Text(state.isRegistering ? S.authRegister : S.authSignIn, key: ValueKey(state.isRegistering)),
                  ),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: state.isWorking ? null : cubit.toggleMode,
                  child: _ModeCrossfade(
                    child: Text(
                      state.isRegistering ? S.authSwitchToSignIn : S.authSwitchToRegister,
                      key: ValueKey(state.isRegistering),
                    ),
                  ),
                ),
                AnimatedSize(
                  duration: BovedaMotion.of(context, state.isRegistering ? BovedaMotion.short : BovedaMotion.medium),
                  curve: BovedaMotion.emphasizedDecelerate,
                  child: state.isRegistering
                      ? const SizedBox(width: double.infinity)
                      : TextButton(
                          onPressed: state.isWorking ? null : cubit.requestPasswordReset,
                          child: const Text(S.authForgot),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Swaps copy between sign-in and registration with a quick cross-fade instead of a cut.
class _ModeCrossfade extends StatelessWidget {
  const _ModeCrossfade({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => AnimatedSwitcher(
        duration: BovedaMotion.of(context, const Duration(milliseconds: 200)),
        reverseDuration: BovedaMotion.of(context, const Duration(milliseconds: 100)),
        switchInCurve: const Interval(0.25, 1),
        layoutBuilder: (current, previous) => Stack(alignment: Alignment.center, children: [...previous, ?current]),
        child: child,
      );
}
