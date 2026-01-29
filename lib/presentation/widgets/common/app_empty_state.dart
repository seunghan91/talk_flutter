import 'package:flutter/material.dart';
import 'package:talk_flutter/core/theme/theme.dart';

/// Empty state widget with icon, title, description, and optional CTA
class AppEmptyState extends StatelessWidget {
  /// Icon to display
  final IconData icon;

  /// Title text
  final String title;

  /// Optional description text
  final String? description;

  /// Optional action button text
  final String? actionText;

  /// Optional action button callback
  final VoidCallback? onAction;

  /// Optional secondary action button text
  final String? secondaryActionText;

  /// Optional secondary action button callback
  final VoidCallback? onSecondaryAction;

  /// Icon size (default: 64)
  final double iconSize;

  /// Icon color (uses theme secondary by default)
  final Color? iconColor;

  const AppEmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.description,
    this.actionText,
    this.onAction,
    this.secondaryActionText,
    this.onSecondaryAction,
    this.iconSize = AppIconSize.hero,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveIconColor =
        iconColor ?? theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6);

    return Center(
      child: Padding(
        padding: AppSpacing.screenPadding,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Animated icon container
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.8, end: 1.0),
              duration: const Duration(milliseconds: 600),
              curve: Curves.elasticOut,
              builder: (context, scale, child) {
                return Transform.scale(
                  scale: scale,
                  child: child,
                );
              },
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.xl),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest
                      .withValues(alpha: 0.5),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: iconSize,
                  color: effectiveIconColor,
                ),
              ),
            ),

            AppSpacing.verticalXl,

            // Title
            Text(
              title,
              style: AppTypography.emptyStateTitle(
                color: theme.colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),

            // Description
            if (description != null) ...[
              AppSpacing.verticalSm,
              Text(
                description!,
                style: AppTypography.emptyStateDescription(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ],

            // Action buttons
            if (actionText != null || secondaryActionText != null) ...[
              AppSpacing.verticalXl,
              Wrap(
                alignment: WrapAlignment.center,
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: [
                  if (actionText != null)
                    FilledButton.icon(
                      onPressed: onAction,
                      icon: const Icon(Icons.add, size: AppIconSize.md),
                      label: Text(actionText!),
                    ),
                  if (secondaryActionText != null)
                    OutlinedButton(
                      onPressed: onSecondaryAction,
                      child: Text(secondaryActionText!),
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ============ Factory Constructors ============

  /// Empty state for no broadcasts
  factory AppEmptyState.noBroadcasts({VoidCallback? onRecord}) {
    return AppEmptyState(
      icon: Icons.campaign_outlined,
      title: '받은 브로드캐스트가 없습니다',
      description: '새로운 음성 메시지를 기다려보세요',
      actionText: onRecord != null ? '브로드캐스트 보내기' : null,
      onAction: onRecord,
    );
  }

  /// Empty state for no conversations
  factory AppEmptyState.noConversations({VoidCallback? onExplore}) {
    return AppEmptyState(
      icon: Icons.chat_bubble_outline,
      title: '대화가 없습니다',
      description: '브로드캐스트에 답장하면 대화가 시작됩니다',
      actionText: onExplore != null ? '브로드캐스트 둘러보기' : null,
      onAction: onExplore,
    );
  }

  /// Empty state for no notifications
  factory AppEmptyState.noNotifications() {
    return const AppEmptyState(
      icon: Icons.notifications_none,
      title: '알림이 없습니다',
      description: '새로운 소식이 있으면 알려드릴게요',
    );
  }

  /// Empty state for no transactions
  factory AppEmptyState.noTransactions({VoidCallback? onDeposit}) {
    return AppEmptyState(
      icon: Icons.receipt_long_outlined,
      title: '거래 내역이 없습니다',
      description: '포인트를 충전하거나 사용하면 여기에 표시됩니다',
      actionText: onDeposit != null ? '포인트 충전' : null,
      onAction: onDeposit,
    );
  }

  /// Empty state for search results
  factory AppEmptyState.noSearchResults({String? query}) {
    return AppEmptyState(
      icon: Icons.search_off,
      title: '검색 결과가 없습니다',
      description: query != null ? '"$query"에 대한 결과를 찾을 수 없습니다' : null,
    );
  }

  /// Empty state for no messages in conversation
  factory AppEmptyState.noMessages({VoidCallback? onSend}) {
    return AppEmptyState(
      icon: Icons.message_outlined,
      title: '아직 메시지가 없습니다',
      description: '첫 번째 메시지를 보내보세요',
      actionText: onSend != null ? '메시지 보내기' : null,
      onAction: onSend,
    );
  }
}
