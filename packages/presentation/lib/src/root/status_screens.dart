import 'package:boveda_designsystem/boveda_designsystem.dart';
import 'package:boveda_domain/boveda_domain.dart';
import 'package:flutter/material.dart';

import '../common/error_messages.dart';
import '../common/strings.dart';

class LoadingScreen extends StatelessWidget {
  const LoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return VaultStage(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: CenteredForm(
          children: [
            const VaultDial(working: true, child: AppEmblem(size: 60)),
            const SizedBox(height: 24),
            Text(S.loadingVault, style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
          ],
        ),
      ),
    );
  }
}

class FailureScreen extends StatelessWidget {
  const FailureScreen({super.key, required this.error, required this.onRetry, required this.onSignOut});

  final AppError error;
  final VoidCallback onRetry;
  final VoidCallback onSignOut;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return VaultStage(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: CenteredForm(
          children: [
            const VaultDial(size: 104, child: AppEmblem(size: 48)),
            const SizedBox(height: 24),
            Text(S.errorScreenTitle, style: theme.textTheme.headlineSmall, textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text(
              errorMessage(error),
              style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 28),
            BovedaButton(
              size: BovedaButtonSize.large,
              fullWidth: true,
              onPressed: onRetry,
              child: const Text(S.retry),
            ),
            const SizedBox(height: 8),
            TextButton(onPressed: onSignOut, child: const Text(S.signOut)),
          ],
        ),
      ),
    );
  }
}
