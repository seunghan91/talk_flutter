import 'package:flutter/material.dart';
import 'package:talk_flutter/core/theme/theme.dart';

/// Friendly error state widget — avoids alarming users with technical details
class AppErrorState extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;
  final String? secondaryActionText;
  final VoidCallback? onSecondaryAction;
  final IconData icon;
  final double iconSize;
  final bool isNetworkError;

  const AppErrorState({
    super.key,
    required this.message,
    this.onRetry,
    this.secondaryActionText,
    this.onSecondaryAction,
    this.icon = Icons.cloud_off_rounded,
    this.iconSize = AppIconSize.hero,
    this.isNetworkError = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveIcon = isNetworkError ? Icons.wifi_off_rounded : icon;

    // 네트워크 오류: muted(연한 분홍), 기타: accent(핑크) 배경
    final iconBgColor = isNetworkError ? AppColors.muted : AppColors.accent;
    final iconColor = AppColors.mutedForeground;

    return Center(
      child: Padding(
        padding: AppSpacing.screenPadding,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            // 아이콘 컨테이너 — 디자인 시스템 색상
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 350),
              curve: Curves.easeOutBack,
              builder: (context, value, child) => Transform.scale(
                scale: value,
                child: Opacity(opacity: value.clamp(0.0, 1.0), child: child),
              ),
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: iconBgColor,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.border),
                ),
                child: Icon(effectiveIcon, size: iconSize, color: iconColor),
              ),
            ),

            const SizedBox(height: AppSpacing.lg),

            // 메시지 — primary 텍스트 컬러
            Text(
              message,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: AppColors.textPrimaryLight,
                fontWeight: FontWeight.w500,
                height: 1.6,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: AppSpacing.xl),

            // 버튼 행
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (onRetry != null)
                  SizedBox(
                    height: 48,
                    child: FilledButton.icon(
                      onPressed: onRetry,
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppRadius.sm),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.xl,
                        ),
                        textStyle: theme.textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      icon: const Icon(Icons.refresh_rounded, size: 18),
                      label: const Text('다시 시도'),
                    ),
                  ),
                if (secondaryActionText != null &&
                    onSecondaryAction != null) ...[
                  const SizedBox(width: AppSpacing.sm),
                  SizedBox(
                    height: 48,
                    child: OutlinedButton(
                      onPressed: onSecondaryAction,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.mutedForeground,
                        side: BorderSide(color: AppColors.border),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppRadius.sm),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.xl,
                        ),
                      ),
                      child: Text(secondaryActionText!),
                    ),
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

  factory AppErrorState.network({VoidCallback? onRetry}) {
    return AppErrorState(
      message: '인터넷 연결이 불안정해요.\n연결 상태를 확인하고 다시 시도해주세요.',
      icon: Icons.wifi_off_rounded,
      isNetworkError: true,
      onRetry: onRetry,
    );
  }

  factory AppErrorState.server({VoidCallback? onRetry, String? details}) {
    return AppErrorState(
      message: '서버가 응답하지 않아요.\n잠시 후 다시 시도해주세요.',
      icon: Icons.cloud_off_rounded,
      onRetry: onRetry,
    );
  }

  factory AppErrorState.generic({
    String? message,
    VoidCallback? onRetry,
  }) {
    return AppErrorState(
      message: message ?? '일시적인 문제가 발생했어요.\n잠시 후 다시 시도해주세요.',
      icon: Icons.refresh_rounded,
      onRetry: onRetry,
    );
  }

  factory AppErrorState.permissionDenied({
    String? feature,
    VoidCallback? onSettings,
  }) {
    return AppErrorState(
      message: feature != null ? '$feature 권한이 필요합니다' : '권한이 필요합니다',
      icon: Icons.lock_outline_rounded,
      secondaryActionText: '설정으로 이동',
      onSecondaryAction: onSettings,
    );
  }

  factory AppErrorState.authRequired({VoidCallback? onLogin}) {
    return AppErrorState(
      message: '로그인이 필요합니다',
      icon: Icons.person_outline_rounded,
      onRetry: onLogin,
    );
  }
}
