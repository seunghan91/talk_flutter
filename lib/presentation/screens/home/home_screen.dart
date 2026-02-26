import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:talk_flutter/core/theme/theme.dart';
import 'package:talk_flutter/domain/entities/broadcast.dart';
import 'package:talk_flutter/presentation/blocs/auth/auth_bloc.dart';
import 'package:talk_flutter/presentation/blocs/broadcast/broadcast_bloc.dart';
import 'package:talk_flutter/presentation/blocs/notification/notification_bloc.dart';
import 'package:talk_flutter/presentation/blocs/notification/notification_state.dart';
import 'package:talk_flutter/presentation/blocs/wallet/wallet_bloc.dart';
import 'package:talk_flutter/presentation/blocs/wallet/wallet_event.dart';
import 'package:talk_flutter/presentation/blocs/wallet/wallet_state.dart';
import 'package:talk_flutter/presentation/widgets/voice_message_player.dart';
import 'package:talk_flutter/presentation/widgets/voice_message_recorder.dart';

/// Home screen - 보이스팅 메인 화면
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? _selectedGender;
  _ViewMode _viewMode = _ViewMode.select;
  Broadcast? _currentBroadcast;

  @override
  void initState() {
    super.initState();
    context.read<BroadcastBloc>().add(const BroadcastListRequested(refresh: true));
    context.read<BroadcastBloc>().add(const BroadcastLimitsRequested());
    try {
      context.read<WalletBloc>().add(const WalletRequested());
    } catch (_) {
      // WalletBloc이 없는 경우 무시
    }
  }

  void _handleReceiveVoice() {
    if (_selectedGender == null) return;

    final authState = context.read<AuthBloc>().state;
    final broadcastState = context.read<BroadcastBloc>().state;

    final filtered = broadcastState.broadcasts
        .where((b) => b.userId != authState.user?.id)
        .where((b) =>
            _selectedGender == null ||
            b.senderGender?.name.toLowerCase() == _selectedGender)
        .toList();

    if (filtered.isNotEmpty) {
      filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      setState(() {
        _currentBroadcast = filtered.first;
        _viewMode = _ViewMode.listening;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('아직 새로운 보이스가 없어요. 조금만 기다려주세요!'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.smallRadius,
          ),
        ),
      );
    }
  }

  void _handleStartRecording() {
    if (_selectedGender == null) return;
    setState(() {
      _viewMode = _ViewMode.recording;
    });
  }

  void _handleNext() {
    setState(() {
      _viewMode = _ViewMode.select;
      _selectedGender = null;
      _currentBroadcast = null;
    });
  }

  void _handleReply() {
    if (_currentBroadcast != null) {
      setState(() {
        _selectedGender = _currentBroadcast!.senderGender?.name.toLowerCase();
        _viewMode = _ViewMode.recording;
      });
    }
  }

  void _handleInlineRecordingComplete(String audioPath, int durationSeconds) {
    context.read<BroadcastBloc>().add(
          BroadcastCreateRequested(
            audioPath: audioPath,
            duration: durationSeconds,
            recipientCount: 5,
            targetGender: _selectedGender,
          ),
        );
    setState(() {
      _viewMode = _ViewMode.select;
      _selectedGender = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<BroadcastBloc, BroadcastState>(
      listenWhen: (previous, current) {
        return (current.status == BroadcastStatus.error &&
                previous.errorMessage != current.errorMessage) ||
            (!previous.createSucceeded && current.createSucceeded);
      },
      listener: (context, state) {
        if (state.status == BroadcastStatus.error && state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage!),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }

        if (state.createSucceeded) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('보이스를 전송했어요.')),
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: Colors.transparent,
          body: SafeArea(
            child: RefreshIndicator(
              color: AppColors.primary,
              onRefresh: () async {
                context
                    .read<BroadcastBloc>()
                    .add(const BroadcastListRequested(refresh: true));
                context.read<BroadcastBloc>().add(const BroadcastLimitsRequested());
              },
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: _buildHeader(context),
                  ),
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: _viewMode == _ViewMode.select
                          ? _buildSelectView(context)
                          : _viewMode == _ViewMode.listening
                              ? _buildListeningView(context)
                              : _buildRecordingView(context),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// 상단 헤더 - 앱 타이틀 + 통계 배지
  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.xs,
      ),
      child: Row(
        children: [
          // 앱 타이틀
          Text(
            '보이스팅',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const Spacer(),
          // 통계 배지들
          Row(
            children: [
              // 남은 메시지 수
              BlocBuilder<BroadcastBloc, BroadcastState>(
                builder: (context, state) {
                  return _StatBadge(
                    icon: Icons.mail_outline,
                    value: '${state.limits.dailyRemaining}',
                  );
                },
              ),
              AppSpacing.horizontalSm,
              // 코인
              BlocBuilder<WalletBloc, WalletState>(
                builder: (context, walletState) {
                  return _StatBadge(
                    icon: Icons.monetization_on_outlined,
                    value: '${walletState.balance}',
                  );
                },
              ),
              AppSpacing.horizontalSm,
              // 알림 벨
              BlocBuilder<NotificationBloc, NotificationState>(
                builder: (context, state) {
                  return _NotificationButton(
                    unreadCount: state.unreadCount,
                    onTap: () => context.push('/notifications'),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 선택 화면 (성별 선택 + 보내기/받기)
  Widget _buildSelectView(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        return BlocBuilder<BroadcastBloc, BroadcastState>(
          builder: (context, broadcastState) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppSpacing.verticalSm,

                  // 환영 카드
                  _WelcomeCard(
                    nickname: authState.user?.nickname ?? 'User',
                  ),

                  AppSpacing.verticalMd,

                  // 새로운 보이스 받기 카드
                  _ActionCard(
                    icon: Icons.volume_up_rounded,
                    iconBackgroundColor:
                        AppColors.primary.withValues(alpha: 0.1),
                    iconColor: AppColors.primary,
                    title: '새로운 보이스 받기',
                    subtitle: '듣고 싶은 목소리를 선택하세요',
                    genderLabel: '성별 선택',
                    femaleLabel: '여성',
                    maleLabel: '남성',
                    selectedGender: _selectedGender,
                    onGenderSelected: (gender) {
                      setState(() => _selectedGender = gender);
                    },
                    buttonText: '새로운 보이스 받기',
                    onButtonPressed:
                        _selectedGender != null ? _handleReceiveVoice : null,
                    isLoading: broadcastState.isLoading,
                  ),

                  AppSpacing.verticalMd,

                  // 내 보이스 보내기 카드
                  _ActionCard(
                    icon: Icons.mic_rounded,
                    iconBackgroundColor:
                        AppColors.accent.withValues(alpha: 0.5),
                    iconColor: AppColors.primary,
                    title: '내 보이스 보내기',
                    subtitle: '마음을 담아 목소리를 전해보세요',
                    genderLabel: '보낼 대상 성별',
                    femaleLabel: '여성에게',
                    maleLabel: '남성에게',
                    selectedGender: _selectedGender,
                    onGenderSelected: (gender) {
                      setState(() => _selectedGender = gender);
                    },
                    buttonText: '보이스 녹음하기',
                    isPrimaryButton: false,
                    onButtonPressed: _selectedGender != null &&
                            broadcastState.limits.canBroadcast
                        ? _handleStartRecording
                        : null,
                  ),

                  AppSpacing.verticalMd,

                  // 안내 배너
                  _InfoBanner(
                    remaining: broadcastState.limits.dailyRemaining,
                    limit: broadcastState.limits.dailyLimit,
                  ),

                  AppSpacing.verticalXl,
                ],
              ),
            );
          },
        );
      },
    );
  }

  /// 듣기 화면
  Widget _buildListeningView(BuildContext context) {
    if (_currentBroadcast == null) return const SizedBox.shrink();

    final broadcast = _currentBroadcast!;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Column(
        children: [
          AppSpacing.verticalLg,

          // 보이스 카드
          _DesignCard(
            child: Column(
              children: [
                // 발신자 아바타
                Container(
                  width: 80,
                  height: 80,
                  decoration: const BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.person,
                    size: 40,
                    color: Colors.white,
                  ),
                ),

                AppSpacing.verticalMd,

                Text(
                  broadcast.senderNickname ?? '익명',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),

                AppSpacing.verticalXs,

                Text(
                  _formatDate(broadcast.createdAt),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: context.mutedForegroundColor,
                      ),
                ),

                AppSpacing.verticalXl,

                // 오디오 플레이어
                if (broadcast.audioUrl != null)
                  VoiceMessagePlayer(
                    audioUrl: broadcast.audioUrl!,
                    durationSeconds: broadcast.duration,
                    sourceType: 'broadcast',
                    sourceId: broadcast.id,
                  )
                else
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                      vertical: AppSpacing.md,
                    ),
                    decoration: BoxDecoration(
                      color: context.mutedColor,
                      borderRadius: AppRadius.extraLargeRadius,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.mic, color: AppColors.primary),
                        AppSpacing.horizontalSm,
                        Text(
                          broadcast.formattedDuration,
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ],
                    ),
                  ),

                if (broadcast.content != null &&
                    broadcast.content!.isNotEmpty) ...[
                  AppSpacing.verticalMd,
                  Text(
                    broadcast.content!,
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),

          AppSpacing.verticalXl,

          // 액션 버튼 3개
          Row(
            children: [
              Expanded(
                child: _ListeningActionButton(
                  icon: Icons.skip_next_rounded,
                  label: '넘기기',
                  onTap: _handleNext,
                ),
              ),
              AppSpacing.horizontalSm,
              Expanded(
                child: _ListeningActionButton(
                  icon: Icons.flag_outlined,
                  label: '신고',
                  onTap: () {
                    context.push('/report/user/${broadcast.userId}');
                  },
                ),
              ),
              AppSpacing.horizontalSm,
              Expanded(
                child: _ListeningActionButton(
                  icon: Icons.reply_rounded,
                  label: '답장',
                  onTap: _handleReply,
                  emphasized: true,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 녹음 화면
  Widget _buildRecordingView(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Column(
        children: [
          AppSpacing.verticalLg,
          _DesignCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  '음성 메시지 녹음',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                  textAlign: TextAlign.center,
                ),
                AppSpacing.verticalXs,
                Text(
                  '마음을 담아 목소리를 들려주세요',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: context.mutedForegroundColor,
                      ),
                  textAlign: TextAlign.center,
                ),
                AppSpacing.verticalMd,
                VoiceMessageRecorder(
                  onRecordingComplete: _handleInlineRecordingComplete,
                  onRecordingCancelled: () {
                    setState(() {
                      _viewMode = _ViewMode.select;
                    });
                  },
                ),
              ],
            ),
          ),
          AppSpacing.verticalMd,
          TextButton.icon(
            onPressed: () {
              setState(() {
                _viewMode = _ViewMode.select;
              });
            },
            icon: const Icon(Icons.close),
            label: const Text('취소'),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.mutedForeground,
            ),
          ),
        ],
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

// ==================== View Mode ====================
enum _ViewMode { select, listening, recording }

// ==================== Design Primitives ====================

/// Standard card decoration used across all cards in the design system.
/// White background, border (AppColors.border), elevation shadow.
class _DesignCard extends StatelessWidget {
  final Widget child;

  const _DesignCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: context.borderColor),
        boxShadow: [
          BoxShadow(
            color: context.shadowColor,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }
}

// ==================== Sub Widgets ====================

/// 헤더 통계 배지 - white card with border, icon + value
class _StatBadge extends StatelessWidget {
  final IconData icon;
  final String value;

  const _StatBadge({
    required this.icon,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: Border.all(color: context.borderColor),
        boxShadow: [
          BoxShadow(
            color: context.shadowColor,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: AppIconSize.md, color: AppColors.primary),
          AppSpacing.horizontalXs,
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.accentForeground,
                ),
          ),
        ],
      ),
    );
  }
}

/// 알림 버튼 with badge
class _NotificationButton extends StatelessWidget {
  final int unreadCount;
  final VoidCallback onTap;

  const _NotificationButton({
    required this.unreadCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: Border.all(color: context.borderColor),
        boxShadow: [
          BoxShadow(
            color: context.shadowColor,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IconButton(
        onPressed: onTap,
        icon: Badge(
          isLabelVisible: unreadCount > 0,
          backgroundColor: AppColors.primary,
          label: Text(
            unreadCount > 99 ? '99+' : '$unreadCount',
            style: const TextStyle(fontSize: 9, color: Colors.white),
          ),
          child: Icon(
            Icons.notifications_outlined,
            color: context.mutedForegroundColor,
          ),
        ),
        style: IconButton.styleFrom(
          padding: const EdgeInsets.all(AppSpacing.xs),
          minimumSize: const Size(36, 36),
        ),
      ),
    );
  }
}

/// 환영 카드
class _WelcomeCard extends StatelessWidget {
  final String nickname;

  const _WelcomeCard({required this.nickname});

  @override
  Widget build(BuildContext context) {
    return _DesignCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '안녕하세요, $nickname님! 👋',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.accentForeground,
                ),
          ),
          AppSpacing.verticalXs,
          Text(
            '오늘도 설레는 목소리를 주고받아보세요',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: context.mutedForegroundColor,
                ),
          ),
        ],
      ),
    );
  }
}

/// 성별 선택 + 액션 카드
class _ActionCard extends StatelessWidget {
  final IconData icon;
  final Color iconBackgroundColor;
  final Color iconColor;
  final String title;
  final String subtitle;
  final String genderLabel;
  final String femaleLabel;
  final String maleLabel;
  final String? selectedGender;
  final ValueChanged<String> onGenderSelected;
  final String buttonText;
  final bool isPrimaryButton;
  final VoidCallback? onButtonPressed;
  final bool isLoading;

  const _ActionCard({
    required this.icon,
    required this.iconBackgroundColor,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.genderLabel,
    required this.femaleLabel,
    required this.maleLabel,
    required this.selectedGender,
    required this.onGenderSelected,
    required this.buttonText,
    this.isPrimaryButton = true,
    required this.onButtonPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return _DesignCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 아이콘 + 타이틀
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: iconBackgroundColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: AppIconSize.lg, color: iconColor),
              ),
              AppSpacing.horizontalSm,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppColors.accentForeground,
                          ),
                    ),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.mutedForeground,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          AppSpacing.verticalMd,

          // 성별 선택 라벨
          Text(
            genderLabel,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: AppColors.accentForeground,
                ),
          ),

          AppSpacing.verticalXs,

          // 성별 선택 버튼
          Row(
            children: [
              Expanded(
                child: _GenderButton(
                  label: femaleLabel,
                  isSelected: selectedGender == 'female',
                  onTap: () => onGenderSelected('female'),
                ),
              ),
              AppSpacing.horizontalSm,
              Expanded(
                child: _GenderButton(
                  label: maleLabel,
                  isSelected: selectedGender == 'male',
                  onTap: () => onGenderSelected('male'),
                ),
              ),
            ],
          ),

          AppSpacing.verticalMd,

          // 메인 버튼
          SizedBox(
            width: double.infinity,
            height: 48,
            child: isPrimaryButton
                ? ElevatedButton(
                    onPressed: isLoading ? null : onButtonPressed,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor:
                          AppColors.primary.withValues(alpha: 0.5),
                      disabledForegroundColor:
                          Colors.white.withValues(alpha: 0.7),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                      ),
                      elevation: 0,
                    ),
                    child: isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            buttonText,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                  )
                : ElevatedButton(
                    onPressed: isLoading ? null : onButtonPressed,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.secondary,
                      foregroundColor: AppColors.accentForeground,
                      disabledBackgroundColor:
                          AppColors.secondary.withValues(alpha: 0.4),
                      disabledForegroundColor:
                          AppColors.accentForeground.withValues(alpha: 0.5),
                      elevation: 0,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                      ),
                    ),
                    child: isLoading
                        ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.accentForeground,
                            ),
                          )
                        : Text(
                            buttonText,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                  ),
          ),
        ],
      ),
    );
  }
}

/// 성별 선택 버튼
class _GenderButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _GenderButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.1)
              : context.mutedColor,
          borderRadius: BorderRadius.circular(AppRadius.sm),
          border: Border.all(
            color: isSelected ? AppColors.primary : context.borderColor,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: isSelected
                      ? AppColors.primary
                      : context.mutedForegroundColor,
                  fontWeight:
                      isSelected ? FontWeight.w600 : FontWeight.w400,
                ),
          ),
        ),
      ),
    );
  }
}

/// 듣기 화면 액션 버튼
class _ListeningActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool emphasized;

  const _ListeningActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.emphasized = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(AppRadius.sm),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        decoration: BoxDecoration(
          color: emphasized
              ? AppColors.primary.withValues(alpha: 0.1)
              : context.mutedColor,
          borderRadius: BorderRadius.circular(AppRadius.sm),
          border: Border.all(
            color: emphasized
                ? AppColors.primary.withValues(alpha: 0.3)
                : context.borderColor,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: AppIconSize.md,
              color: emphasized ? AppColors.primary : AppColors.mutedForeground,
            ),
            AppSpacing.verticalXxs,
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: emphasized
                        ? AppColors.primary
                        : AppColors.mutedForeground,
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 안내 배너 - accent/50 background, centered text, rounded-xl, border
class _InfoBanner extends StatelessWidget {
  final int remaining;
  final int limit;

  const _InfoBanner({
    required this.remaining,
    required this.limit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: context.accentColor,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: Border.all(color: context.borderColor),
      ),
      child: Text(
        '💡 하루에 $limit개의 메시지를 보낼 수 있어요.\n현재 남은 횟수: $remaining개',
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: context.mutedForegroundColor,
              height: 1.5,
            ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
