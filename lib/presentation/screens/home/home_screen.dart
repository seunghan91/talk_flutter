import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:talk_flutter/core/theme/theme.dart';
import 'package:talk_flutter/domain/entities/broadcast.dart';
import 'package:talk_flutter/presentation/blocs/auth/auth_bloc.dart';
import 'package:talk_flutter/presentation/blocs/broadcast/broadcast_bloc.dart';
import 'package:talk_flutter/presentation/blocs/notification/notification_bloc.dart';
import 'package:talk_flutter/presentation/blocs/notification/notification_state.dart';
import 'package:talk_flutter/presentation/widgets/common/common_widgets.dart';
import 'package:talk_flutter/presentation/widgets/voice_message_player.dart';

/// Home screen displaying received broadcasts
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Load broadcasts on init
    context.read<BroadcastBloc>().add(const BroadcastListRequested(refresh: true));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Talkk'),
        actions: [
          // Notification bell with unread badge
          BlocBuilder<NotificationBloc, NotificationState>(
            builder: (context, state) {
              return IconButton(
                icon: Badge(
                  isLabelVisible: state.unreadCount > 0,
                  label: Text(
                    state.unreadCount > 99 ? '99+' : '${state.unreadCount}',
                    style: AppTypography.badge(),
                  ),
                  child: const Icon(Icons.notifications_outlined),
                ),
                onPressed: () => context.push('/notifications'),
              );
            },
          ),
        ],
      ),
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, authState) {
          return BlocBuilder<BroadcastBloc, BroadcastState>(
            builder: (context, broadcastState) {
              return RefreshIndicator(
                onRefresh: () async {
                  context.read<BroadcastBloc>().add(const BroadcastListRequested(refresh: true));
                },
                child: CustomScrollView(
                  slivers: [
                    // Welcome header
                    SliverToBoxAdapter(
                      child: _WelcomeHeader(
                        nickname: authState.user?.nickname ?? 'User',
                      ),
                    ),

                    // Loading indicator with skeleton
                    if (broadcastState.isLoading && broadcastState.broadcasts.isEmpty)
                      SliverFillRemaining(
                        child: SkeletonList.broadcasts(count: 3),
                      )
                    // Error state
                    else if (broadcastState.status == BroadcastStatus.error &&
                             broadcastState.broadcasts.isEmpty)
                      SliverFillRemaining(
                        child: AppErrorState.generic(
                          message: broadcastState.errorMessage ?? '오류가 발생했습니다',
                          onRetry: () {
                            context.read<BroadcastBloc>().add(
                              const BroadcastListRequested(refresh: true),
                            );
                          },
                        ),
                      )
                    // Empty state with CTA
                    else if (broadcastState.broadcasts.isEmpty)
                      SliverFillRemaining(
                        child: AppEmptyState.noBroadcasts(
                          onRecord: () => context.push('/broadcast/record'),
                        ),
                      )
                    // Broadcasts list - only show received (not sent by me)
                    else
                      SliverPadding(
                        padding: const EdgeInsets.all(16),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              // Filter received broadcasts only
                              final receivedBroadcasts = broadcastState.broadcasts
                                  .where((b) => b.userId != authState.user?.id)
                                  .toList();

                              if (index >= receivedBroadcasts.length) return null;

                              final broadcast = receivedBroadcasts[index];
                              return _BroadcastCard(
                                broadcast: broadcast,
                                onTap: () {
                                  context.push('/broadcast/${broadcast.id}');
                                },
                                onReply: () {
                                  context.push('/broadcast/reply/${broadcast.id}');
                                },
                              );
                            },
                            childCount: broadcastState.broadcasts
                                .where((b) => b.userId != authState.user?.id)
                                .length,
                          ),
                        ),
                      ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _WelcomeHeader extends StatelessWidget {
  final String nickname;

  const _WelcomeHeader({required this.nickname});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.secondary,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '안녕하세요, $nickname님!',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            '오늘 받은 음성 메시지를 확인해보세요',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white.withValues(alpha: 0.9),
                ),
          ),
        ],
      ),
    );
  }
}

class _BroadcastCard extends StatelessWidget {
  final Broadcast broadcast;
  final VoidCallback onTap;
  final VoidCallback onReply;

  const _BroadcastCard({
    required this.broadcast,
    required this.onTap,
    required this.onReply,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with user info
              Row(
                children: [
                  AppAvatar(
                    name: broadcast.senderNickname,
                    radius: AppAvatarSize.sm,
                  ),
                  AppSpacing.horizontalSm,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                broadcast.senderNickname ?? '알 수 없음',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (!broadcast.isRead) ...[
                              AppSpacing.horizontalXs,
                              const AppDotIndicator(animate: true),
                            ],
                          ],
                        ),
                        Text(
                          _formatDate(broadcast.createdAt),
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                        ),
                      ],
                    ),
                  ),
                  if (broadcast.isExpiringSoon) ...[
                    AppSpacing.horizontalXs,
                    AppBadge.expiring(),
                  ],
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'report') {
                        context.push('/report/user/${broadcast.userId}');
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'report',
                        child: Row(
                          children: [
                            Icon(Icons.flag_outlined),
                            SizedBox(width: 8),
                            Text('신고하기'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Audio player
              if (broadcast.audioUrl != null)
                VoiceMessagePlayer(
                  audioUrl: broadcast.audioUrl!,
                  durationSeconds: broadcast.duration,
                )
              else
                // Placeholder if no audio
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.mic,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        broadcast.formattedDuration,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),

              // Content text if exists
              if (broadcast.content != null && broadcast.content!.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  broadcast.content!,
                  style: Theme.of(context).textTheme.bodyMedium,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],

              const SizedBox(height: 12),

              // Actions
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    onPressed: onReply,
                    icon: const Icon(Icons.reply),
                    label: const Text('답장하기'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
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
