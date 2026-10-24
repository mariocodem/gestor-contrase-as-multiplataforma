import 'package:boveda_designsystem/boveda_designsystem.dart';
import 'package:boveda_domain/boveda_domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../common/error_messages.dart';
import '../common/messages.dart';
import '../common/strings.dart';

class LoadingScreen extends StatelessWidget {
  const LoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: systemBarsOver(theme.colorScheme.surface, theme.colorScheme.surface),
      child: Scaffold(
        body: CenteredForm(
          children: [
            const AppEmblem(),
            const SizedBox(height: 28),
            const SizedBox(width: 160, child: LinearProgressIndicator()),
            const SizedBox(height: 16),
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
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: systemBarsOver(theme.colorScheme.surface, theme.colorScheme.surface),
      child: Scaffold(
        body: CenteredForm(
          children: [
            const AppEmblem(),
            const SizedBox(height: 24),
            Text(S.errorScreenTitle, style: theme.textTheme.headlineSmall, textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text(
              errorMessage(error),
              style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: FilledButton(onPressed: onRetry, child: const Text(S.retry)),
            ),
            const SizedBox(height: 8),
            TextButton(onPressed: onSignOut, child: const Text(S.signOut)),
          ],
        ),
      ),
    );
  }
}
