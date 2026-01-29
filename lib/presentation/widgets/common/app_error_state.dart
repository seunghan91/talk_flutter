import 'package:flutter/material.dart';
import 'package:talk_flutter/core/theme/theme.dart';

/// Error state widget with icon, message, and retry button
class AppErrorState extends StatelessWidget {
  /// Error message to display
  final String message;

  /// Optional error details (for developers)
  final String? details;

  /// Retry button callback
  final VoidCallback? onRetry;

  /// Optional secondary action
  final String? secondaryActionText;
  final VoidCallback? onSecondaryAction;

  /// Icon to display (default: error_outline)
  final IconData icon;

  /// Icon size
  final double iconSize;

  /// Whether this is a network error
  final bool isNetworkError;

  const AppErrorState({
    super.key,
    required this.message,
    this.details,
    this.onRetry,
    this.secondaryActionText,
    this.onSecondaryAction,
    this.icon = Icons.error_outline,
    this.iconSize = AppIconSize.hero,
    this.isNetworkError = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: AppSpacing.screenPadding,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Animated error icon
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeOutBack,
              builder: (context, value, child) {
                return Transform.scale(
                  scale: value,
                  child: Opacity(
                    opacity: value,
                    child: child,
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  color: theme.colorScheme.errorContainer.withValues(alpha: 0.3),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isNetworkError ? Icons.wifi_off : icon,
                  size: iconSize,
                  color: theme.colorScheme.error,
                ),
              ),
            ),

            AppSpacing.verticalXl,

            // Error message
            Text(
              message,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurface,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),

            // Error details (if provided and in debug mode)
            if (details != null) ...[
              AppSpacing.verticalSm,
              Container(
                padding: AppSpacing.cardPadding,
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: AppRadius.smallRadius,
                ),
                child: Text(
                  details!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontFamily: 'monospace',
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],

            AppSpacing.verticalXl,

            // Action buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (onRetry != null)
                  FilledButton.icon(
                    onPressed: onRetry,
                    icon: const Icon(Icons.refresh, size: AppIconSize.md),
                    label: const Text('다시 시도'),
                  ),
                if (secondaryActionText != null && onSecondaryAction != null) ...[
                  AppSpacing.horizontalSm,
                  OutlinedButton(
                    onPressed: onSecondaryAction,
                    child: Text(secondaryActionText!),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ============ Factory Constructors ============

  /// Network error state
  factory AppErrorState.network({VoidCallback? onRetry}) {
    return AppErrorState(
      message: '네트워크 연결을 확인해주세요',
      icon: Icons.wifi_off,
      isNetworkError: true,
      onRetry: onRetry,
    );
  }

  /// Server error state
  factory AppErrorState.server({VoidCallback? onRetry, String? details}) {
    return AppErrorState(
      message: '서버 오류가 발생했습니다',
      details: details,
      icon: Icons.cloud_off,
      onRetry: onRetry,
    );
  }

  /// Generic error state
  factory AppErrorState.generic({
    String? message,
    VoidCallback? onRetry,
  }) {
    return AppErrorState(
      message: message ?? '오류가 발생했습니다',
      onRetry: onRetry,
    );
  }

  /// Permission denied error
  factory AppErrorState.permissionDenied({
    String? feature,
    VoidCallback? onSettings,
  }) {
    return AppErrorState(
      message: feature != null ? '$feature 권한이 필요합니다' : '권한이 필요합니다',
      icon: Icons.lock_outline,
      secondaryActionText: '설정으로 이동',
      onSecondaryAction: onSettings,
    );
  }

  /// Authentication error
  factory AppErrorState.authRequired({VoidCallback? onLogin}) {
    return AppErrorState(
      message: '로그인이 필요합니다',
      icon: Icons.person_outline,
      onRetry: onLogin,
    );
  }
}
