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
      body: SafeArea(
        child: BlocBuilder<AuthBloc, AuthState>(
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
                          padding: AppSpacing.screenPadding,
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
      ),
    );
  }
}

class _WelcomeHeader extends StatelessWidget {
  final String nickname;

  const _WelcomeHeader({required this.nickname});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colorScheme.primary,
            colorScheme.secondary,
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
                  color: colorScheme.onPrimary,
                  fontWeight: FontWeight.bold,
                ),
          ),
          AppSpacing.verticalXs,
          Text(
            '오늘 받은 음성 메시지를 확인해보세요',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onPrimary.withValues(alpha: 0.9),
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
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      margin: EdgeInsets.only(bottom: AppSpacing.sm),
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.mediumRadius,
        child: Padding(
          padding: AppSpacing.cardPadding,
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
                                color: colorScheme.onSurfaceVariant,
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
                      PopupMenuItem(
                        value: 'report',
                        child: Row(
                          children: [
                            const Icon(Icons.flag_outlined),
                            AppSpacing.horizontalXs,
                            const Text('신고하기'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              AppSpacing.verticalMd,

              // Audio player
              if (broadcast.audioUrl != null)
                VoiceMessagePlayer(
                  audioUrl: broadcast.audioUrl!,
                  durationSeconds: broadcast.duration,
                )
              else
                // Placeholder if no audio
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest,
                    borderRadius: AppRadius.extraLargeRadius,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.mic,
                        color: colorScheme.primary,
                      ),
                      AppSpacing.horizontalSm,
                      Text(
                        broadcast.formattedDuration,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),

              // Content text if exists
              if (broadcast.content != null && broadcast.content!.isNotEmpty) ...[
                AppSpacing.verticalSm,
                Text(
                  broadcast.content!,
                  style: Theme.of(context).textTheme.bodyMedium,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],

              AppSpacing.verticalSm,

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
