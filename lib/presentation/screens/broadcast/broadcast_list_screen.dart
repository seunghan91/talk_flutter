import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:talk_flutter/core/theme/theme.dart';
import 'package:talk_flutter/domain/entities/broadcast.dart';
import 'package:talk_flutter/presentation/blocs/auth/auth_bloc.dart';
import 'package:talk_flutter/presentation/blocs/broadcast/broadcast_bloc.dart';

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
        appBar: AppBar(
        title: const Text('브로드캐스트'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: '받은 브로드캐스트'),
            Tab(text: '보낸 브로드캐스트'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.mic),
            onPressed: () => context.push('/broadcast/record'),
            tooltip: '새 브로드캐스트',
          ),
        ],
      ),
      body: BlocConsumer<BroadcastBloc, BroadcastState>(
        listener: (context, state) {
          if (state.status == BroadcastStatus.error && state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage!),
                backgroundColor: Theme.of(context).colorScheme.error,
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
                  // Received broadcasts (not sent by me)
                  _BroadcastList(
                    broadcasts: state.broadcasts
                        .where((b) => b.userId != currentUserId)
                        .toList(),
                    isLoading: state.isLoading,
                    onRefresh: () async {
                      context.read<BroadcastBloc>().add(const BroadcastListRequested(refresh: true));
                    },
                    emptyMessage: '받은 브로드캐스트가 없습니다',
                    emptyIcon: Icons.campaign_outlined,
                  ),
                  // Sent broadcasts (sent by me)
                  _BroadcastList(
                    broadcasts: state.broadcasts
                        .where((b) => b.userId == currentUserId)
                        .toList(),
                    isLoading: state.isLoading,
                    onRefresh: () async {
                      context.read<BroadcastBloc>().add(const BroadcastListRequested(refresh: true));
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
          icon: const Icon(Icons.mic),
          label: const Text('새 브로드캐스트'),
        ),
      ),
    );
  }
}

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
      return const Center(child: CircularProgressIndicator());
    }

    if (broadcasts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              emptyIcon,
              size: AppIconSize.hero,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            AppSpacing.verticalMd,
            Text(
              emptyMessage,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
        itemCount: broadcasts.length,
        itemBuilder: (context, index) {
          final broadcast = broadcasts[index];
          return _BroadcastTile(broadcast: broadcast);
        },
      ),
    );
  }
}

class _BroadcastTile extends StatelessWidget {
  final Broadcast broadcast;

  const _BroadcastTile({required this.broadcast});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xxs),
      child: InkWell(
        onTap: () => context.push('/broadcast/${broadcast.id}'),
        borderRadius: AppRadius.cardRadius,
        child: Padding(
          padding: AppSpacing.cardPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                    child: Text(
                      broadcast.senderNickname?.substring(0, 1).toUpperCase() ?? '?',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  AppSpacing.horizontalSm,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          broadcast.senderNickname ?? '알 수 없음',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
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
                  if (!broadcast.isRead)
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                ],
              ),
              if (broadcast.content != null && broadcast.content!.isNotEmpty) ...[
                AppSpacing.verticalSm,
                Text(
                  broadcast.content!,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
              AppSpacing.verticalSm,
              Row(
                children: [
                  Icon(
                    Icons.mic,
                    size: AppIconSize.sm,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  AppSpacing.horizontalXxs,
                  Text(
                    broadcast.formattedDuration,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                  ),
                  const Spacer(),
                  if (broadcast.isExpiringSoon)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs, vertical: 2),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.errorContainer,
                        borderRadius: AppRadius.mediumRadius,
                      ),
                      child: Text(
                        '곧 만료',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: Theme.of(context).colorScheme.onErrorContainer,
                            ),
                      ),
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
