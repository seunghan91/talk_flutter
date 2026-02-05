import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:talk_flutter/core/theme/theme.dart';
import 'package:talk_flutter/domain/entities/notification.dart';
import 'package:talk_flutter/presentation/blocs/notification/notification_bloc.dart';
import 'package:talk_flutter/presentation/blocs/notification/notification_event.dart';
import 'package:talk_flutter/presentation/blocs/notification/notification_state.dart';

/// Notification list screen
class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  @override
  void initState() {
    super.initState();
    context.read<NotificationBloc>().add(const NotificationListRequested(refresh: true));
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('알림'),
        actions: [
          BlocBuilder<NotificationBloc, NotificationState>(
            builder: (context, state) {
              if (state.unreadCount > 0) {
                return TextButton(
                  onPressed: () {
                    context.read<NotificationBloc>().add(const NotificationMarkAllAsRead());
                  },
                  child: const Text('모두 읽음'),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: SafeArea(
        child: BlocConsumer<NotificationBloc, NotificationState>(
          listener: (context, state) {
            if (state.successMessage != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.successMessage!)),
              );
            } else if (state.hasError && state.errorMessage != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.errorMessage!),
                  backgroundColor: colorScheme.error,
                ),
              );
            }
          },
          builder: (context, state) {
            if (state.isLoading && state.notifications.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }

            if (!state.hasNotifications) {
              return _buildEmptyState();
            }

            return RefreshIndicator(
              onRefresh: () async {
                context.read<NotificationBloc>().add(const NotificationListRequested(refresh: true));
              },
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
                itemCount: state.notifications.length,
                separatorBuilder: (context, index) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final notification = state.notifications[index];
                  return _NotificationTile(
                    notification: notification,
                    onTap: () => _onNotificationTap(notification),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_off_outlined,
            size: AppIconSize.hero,
            color: colorScheme.onSurfaceVariant,
          ),
          AppSpacing.verticalMd,
          Text(
            '알림이 없습니다',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
          ),
        ],
      ),
    );
  }

  void _onNotificationTap(AppNotification notification) {
    if (!notification.isRead) {
      context.read<NotificationBloc>().add(NotificationMarkAsRead(notification.id));
    }

    // Navigate based on notification type
    final metadata = notification.metadata;
    if (metadata != null) {
      final broadcastId = metadata['broadcast_id'];
      final conversationId = metadata['conversation_id'];

      if (conversationId != null) {
        // Navigate to conversation
      } else if (broadcastId != null) {
        // Navigate to broadcast
      }
    }
  }
}

class _NotificationTile extends StatelessWidget {
  final AppNotification notification;
  final VoidCallback onTap;

  const _NotificationTile({
    required this.notification,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: notification.isRead
            ? colorScheme.surfaceContainerHighest
            : colorScheme.primaryContainer,
        child: Icon(
          _getIcon(),
          color: notification.isRead
              ? colorScheme.onSurfaceVariant
              : colorScheme.primary,
        ),
      ),
      title: Text(
        notification.title ?? notification.typeDisplayName,
        style: TextStyle(
          fontWeight: notification.isRead ? FontWeight.normal : FontWeight.bold,
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (notification.body != null)
            Text(
              notification.body!,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          AppSpacing.verticalXxs,
          Text(
            notification.formattedDate ?? _formatDate(notification.createdAt),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
          ),
        ],
      ),
      trailing: !notification.isRead
          ? Container(
              width: AppSpacing.xs,
              height: AppSpacing.xs,
              decoration: BoxDecoration(
                color: colorScheme.primary,
                shape: BoxShape.circle,
              ),
            )
          : null,
      onTap: onTap,
    );
  }

  IconData _getIcon() {
    switch (notification.type) {
      case 'broadcast':
        return Icons.campaign;
      case 'message':
        return Icons.message;
      case 'reply':
        return Icons.reply;
      case 'system':
        return Icons.info_outline;
      default:
        return Icons.notifications;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays}일 전';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}시간 전';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}분 전';
    } else {
      return '방금 전';
    }
  }
}
