import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:talk_flutter/core/enums/app_enums.dart';
import 'package:talk_flutter/core/theme/theme.dart';
import 'package:talk_flutter/domain/entities/broadcast.dart';
import 'package:talk_flutter/presentation/blocs/auth/auth_bloc.dart';
import 'package:talk_flutter/presentation/blocs/broadcast/broadcast_bloc.dart';
import 'package:talk_flutter/presentation/widgets/voice_message_player.dart';

/// Broadcast list screen - shows sent and received broadcasts
class BroadcastListScreen extends StatefulWidget {
  const BroadcastListScreen({super.key});

  @override
  State<BroadcastListScreen> createState() => _BroadcastListScreenState();
}

class _BroadcastListScreenState extends State<BroadcastListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    context.read<BroadcastBloc>().add(const BroadcastListRequested(refresh: true));
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: context.cardColor,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          title: const Text('브로드캐스트'),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(48),
            child: Container(
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: context.borderColor),
                ),
              ),
              child: TabBar(
                controller: _tabController,
                labelColor: AppColors.primary,
                unselectedLabelColor: context.mutedForegroundColor,
                indicatorColor: AppColors.primary,
                indicatorWeight: 2,
                tabs: const [
                  Tab(text: '받은 브로드캐스트'),
                  Tab(text: '보낸 브로드캐스트'),
                ],
              ),
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.mic, color: AppColors.primary),
              onPressed: () => context.push('/broadcast/record'),
              tooltip: '새 브로드캐스트',
            ),
          ],
        ),
        body: BlocConsumer<BroadcastBloc, BroadcastState>(
          listener: (context, state) {
            if (state.status == BroadcastStatus.error &&
                state.errorMessage != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.errorMessage!),
                  backgroundColor: AppColors.error,
                ),
              );
            }
          },
          builder: (context, state) {
            return BlocBuilder<AuthBloc, AuthState>(
              builder: (context, authState) {
                final currentUserId = authState.user?.id;

                return TabBarView(
                  controller: _tabController,
                  children: [
                    // Received broadcasts
                    _BroadcastList(
                      broadcasts: state.broadcasts
                          .where((b) => b.userId != currentUserId)
                          .toList(),
                      isLoading: state.isLoading,
                      onRefresh: () async {
                        context.read<BroadcastBloc>().add(
                              const BroadcastListRequested(refresh: true),
                            );
                      },
                      emptyMessage: '받은 브로드캐스트가 없습니다',
                      emptyIcon: Icons.campaign_outlined,
                    ),
                    // Sent broadcasts
                    _BroadcastList(
                      broadcasts: state.broadcasts
                          .where((b) => b.userId == currentUserId)
                          .toList(),
                      isLoading: state.isLoading,
                      onRefresh: () async {
                        context.read<BroadcastBloc>().add(
                              const BroadcastListRequested(refresh: true),
                            );
                      },
                      emptyMessage: '보낸 브로드캐스트가 없습니다',
                      emptyIcon: Icons.send_outlined,
                    ),
                  ],
                );
              },
            );
          },
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => context.push('/broadcast/record'),
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          icon: const Icon(Icons.mic),
          label: const Text('새 브로드캐스트'),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Broadcast list
// ---------------------------------------------------------------------------

class _BroadcastList extends StatelessWidget {
  final List<Broadcast> broadcasts;
  final bool isLoading;
  final Future<void> Function() onRefresh;
  final String emptyMessage;
  final IconData emptyIcon;

  const _BroadcastList({
    required this.broadcasts,
    required this.isLoading,
    required this.onRefresh,
    required this.emptyMessage,
    required this.emptyIcon,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading && broadcasts.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    if (broadcasts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: context.mutedColor,
                shape: BoxShape.circle,
              ),
              child: Icon(
                emptyIcon,
                size: AppIconSize.xxl,
                color: context.mutedForegroundColor,
              ),
            ),
            AppSpacing.verticalMd,
            Text(
              emptyMessage,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: context.mutedForegroundColor,
                  ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: onRefresh,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        itemCount: broadcasts.length,
        itemBuilder: (context, index) {
          final broadcast = broadcasts[index];
          return _BroadcastCard(broadcast: broadcast);
        },
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Broadcast card
// ---------------------------------------------------------------------------

class _BroadcastCard extends StatelessWidget {
  final Broadcast broadcast;

  const _BroadcastCard({required this.broadcast});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/broadcast/${broadcast.id}'),
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.sm),
        decoration: BoxDecoration(
          color: context.cardColor,
          borderRadius: BorderRadius.circular(AppRadius.xl),
          border: Border.all(color: context.borderColor),
          boxShadow: [
            BoxShadow(
              color: context.shadowColor,
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Sender row
              Row(
                children: [
                  // Avatar 48x48
                  _BroadcastAvatar(
                    name: broadcast.senderNickname,
                    size: 48,
                    isUnread: !broadcast.isRead,
                  ),
                  AppSpacing.horizontalSm,

                  // Name + gender + time
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                broadcast.senderNickname ?? '알 수 없음',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleSmall
                                    ?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: context.textPrimary,
                                    ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (broadcast.senderGender != null &&
                                broadcast.senderGender != Gender.unknown) ...[
                              AppSpacing.horizontalXs,
                              _GenderBadge(gender: broadcast.senderGender!),
                            ],
                          ],
                        ),
                        AppSpacing.verticalXxs,
                        Text(
                          _formatDate(broadcast.createdAt),
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(color: context.mutedForegroundColor),
                        ),
                      ],
                    ),
                  ),

                  // Unread indicator
                  if (!broadcast.isRead)
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                ],
              ),

              // Optional text content
              if (broadcast.content != null &&
                  broadcast.content!.isNotEmpty) ...[
                AppSpacing.verticalSm,
                Text(
                  broadcast.content!,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: context.textPrimary,
                      ),
                ),
              ],

              AppSpacing.verticalSm,

              // Audio player
              if (broadcast.audioUrl != null)
                _StyledAudioPlayer(broadcast: broadcast)
              else
                _DurationRow(broadcast: broadcast),

              // Bottom row: reply/skip actions
              AppSpacing.verticalSm,
              Row(
                children: [
                  Expanded(
                    child: _ActionButton(
                      label: '답장',
                      icon: Icons.reply_rounded,
                      isPrimary: true,
                      onTap: () => context.push(
                        '/broadcast/${broadcast.id}/reply',
                      ),
                    ),
                  ),
                  AppSpacing.horizontalSm,
                  Expanded(
                    child: _ActionButton(
                      label: '넘기기',
                      icon: Icons.skip_next_rounded,
                      isPrimary: false,
                      onTap: () {},
                    ),
                  ),
                ],
              ),

              // Expiring soon badge
              if (broadcast.isExpiringSoon) ...[
                AppSpacing.verticalXs,
                Align(
                  alignment: Alignment.centerRight,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.xs,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.error.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppRadius.full),
                    ),
                    child: Text(
                      '곧 만료',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: AppColors.error,
                          ),
                    ),
                  ),
                ),
              ],
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

// ---------------------------------------------------------------------------
// Styled audio player wrapper
// ---------------------------------------------------------------------------

class _StyledAudioPlayer extends StatelessWidget {
  final Broadcast broadcast;

  const _StyledAudioPlayer({required this.broadcast});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: context.mutedColor,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: context.borderColor),
      ),
      child: VoiceMessagePlayer(
        audioUrl: broadcast.audioUrl!,
        durationSeconds: broadcast.duration,
        isSentByMe: false,
        sourceType: 'broadcast',
        sourceId: broadcast.id,
      ),
    );
  }
}

/// Fallback when there is no audio URL
class _DurationRow extends StatelessWidget {
  final Broadcast broadcast;

  const _DurationRow({required this.broadcast});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.mic, size: AppIconSize.sm, color: AppColors.primary),
        AppSpacing.horizontalXxs,
        Text(
          broadcast.formattedDuration,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.primary,
              ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Action button (답장 / 넘기기)
// ---------------------------------------------------------------------------

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isPrimary;
  final VoidCallback onTap;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.isPrimary,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 40,
        decoration: BoxDecoration(
          color: isPrimary
              ? AppColors.primary
              : context.mutedColor,
          borderRadius: BorderRadius.circular(AppRadius.sm),
          border: Border.all(
            color: isPrimary ? AppColors.primary : context.borderColor,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: AppIconSize.sm,
              color: isPrimary ? Colors.white : context.mutedForegroundColor,
            ),
            AppSpacing.horizontalXxs,
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: isPrimary ? Colors.white : context.mutedForegroundColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Broadcast avatar
// ---------------------------------------------------------------------------

class _BroadcastAvatar extends StatelessWidget {
  final String? name;
  final double size;
  final bool isUnread;

  const _BroadcastAvatar({
    this.name,
    required this.size,
    this.isUnread = false,
  });

  @override
  Widget build(BuildContext context) {
    final initial =
        (name != null && name!.isNotEmpty) ? name![0].toUpperCase() : '?';

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.12),
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        initial,
        style: TextStyle(
          color: AppColors.primary,
          fontWeight: FontWeight.bold,
          fontSize: size * 0.36,
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Gender badge (shared)
// ---------------------------------------------------------------------------

class _GenderBadge extends StatelessWidget {
  final Gender gender;

  const _GenderBadge({required this.gender});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.secondary.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
      child: Text(
        gender.displayName,
        style: TextStyle(
          fontSize: 10,
          color: context.textPrimary,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
