import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:talk_flutter/core/enums/app_enums.dart';
import 'package:talk_flutter/core/theme/theme.dart';
import 'package:talk_flutter/presentation/blocs/auth/auth_bloc.dart';
import 'package:talk_flutter/presentation/blocs/feedback/feedback_bloc.dart';
import 'package:talk_flutter/presentation/blocs/locale/locale_cubit.dart';
import 'package:talk_flutter/presentation/blocs/theme/theme_cubit.dart';
import 'package:talk_flutter/presentation/blocs/user/user_bloc.dart';
import 'package:talk_flutter/presentation/blocs/wallet/wallet_bloc.dart';
import 'package:talk_flutter/presentation/blocs/wallet/wallet_event.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  void initState() {
    super.initState();
    try {
      context.read<WalletBloc>().add(const WalletRequested());
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            return ListView(
              padding: AppSpacing.screenPadding,
              children: [
                // 커스텀 헤더
                Padding(
                  padding: const EdgeInsets.only(
                    bottom: AppSpacing.lg,
                    top: AppSpacing.xs,
                  ),
                  child: Text(
                    '설정',
                    style:
                        Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                  ),
                ),

                // 프로필 카드
                _ProfileCard(
                  nickname: state.user?.nickname ?? 'User',
                  phoneNumber: state.user?.phoneNumber ?? '',
                  gender: state.user?.gender,
                  onEditTap: () => context.push('/settings/profile'),
                ),
                AppSpacing.verticalMd,

                // 내 보이스 카드
                _MyVoicesCard(
                  onTap: () => context.push('/my-voices'),
                ),
                AppSpacing.verticalMd,

                // 운영진 피드백 카드
                const _FeedbackCard(),
                AppSpacing.verticalMd,

                // 알림 설정 카드
                _NotificationsCard(
                  user: state.user,
                ),
                AppSpacing.verticalMd,

                // 일반 설정 카드
                const _GeneralCard(),
                AppSpacing.verticalMd,

                // 지원 카드
                const _SupportCard(),
                AppSpacing.verticalMd,

                // 앱 정보
                const _AppInfoCard(),
                AppSpacing.verticalMd,

                // 로그아웃 버튼
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: () => _showLogoutDialog(context),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.error,
                    ),
                    child: const Text('로그아웃'),
                  ),
                ),
                AppSpacing.verticalXxl,
              ],
            );
          },
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('로그아웃'),
        content: const Text('정말 로그아웃 하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<AuthBloc>().add(const AuthLogoutRequested());
            },
            child: Text(
              '로그아웃',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// 공통 카드 데코레이션 (다크/라이트 모드 대응)
// ─────────────────────────────────────────────────────────────

BoxDecoration _cardDecoration(BuildContext context) {
  return BoxDecoration(
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
  );
}

// ─────────────────────────────────────────────────────────────
// 프로필 카드
// ─────────────────────────────────────────────────────────────

class _ProfileCard extends StatelessWidget {
  final String nickname;
  final String phoneNumber;
  final Gender? gender;
  final VoidCallback onEditTap;

  const _ProfileCard({
    required this.nickname,
    required this.phoneNumber,
    required this.onEditTap,
    this.gender,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: _cardDecoration(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 카드 헤더
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppRadius.full),
                ),
                child: const Icon(
                  Icons.person_outline,
                  color: AppColors.primary,
                  size: AppIconSize.xl,
                ),
              ),
              AppSpacing.horizontalSm,
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '내 프로필',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  Text(
                    '내 정보를 확인하세요',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: context.mutedForegroundColor,
                        ),
                  ),
                ],
              ),
            ],
          ),
          AppSpacing.verticalMd,

          // 닉네임 row
          _ProfileRow(
            label: '닉네임',
            value: nickname,
          ),
          Divider(height: 24, color: Theme.of(context).dividerColor),

          // 전화번호 / 성별 row
          _ProfileRow(
            label: '전화번호',
            value: phoneNumber.isNotEmpty ? phoneNumber : '-',
          ),
          if (gender != null && gender != Gender.unknown) ...[
            Divider(height: 24, color: Theme.of(context).dividerColor),
            _ProfileRow(
              label: '성별',
              value: gender!.displayName,
            ),
          ],
          AppSpacing.verticalMd,

          // 프로필 수정 버튼
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: onEditTap,
              style: TextButton.styleFrom(
                backgroundColor: context.mutedColor,
                foregroundColor: context.textPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                padding:
                    const EdgeInsets.symmetric(vertical: AppSpacing.sm),
              ),
              child: const Text(
                '프로필 수정',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileRow extends StatelessWidget {
  final String label;
  final String value;

  const _ProfileRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: context.mutedForegroundColor,
              ),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────
// 내 보이스 카드
// ─────────────────────────────────────────────────────────────

class _MyVoicesCard extends StatelessWidget {
  final VoidCallback onTap;

  const _MyVoicesCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.xl),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: _cardDecoration(context),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: context.secondaryColor.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(AppRadius.full),
              ),
              child: const Icon(
                Icons.volume_up_outlined,
                color: AppColors.primary,
                size: AppIconSize.xl,
              ),
            ),
            AppSpacing.horizontalSm,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '내 보이스',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  Text(
                    '내가 보낸 보이스 메시지',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: context.mutedForegroundColor,
                        ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: context.textTertiary,
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// 운영진 피드백 카드
// ─────────────────────────────────────────────────────────────

class _FeedbackCard extends StatefulWidget {
  const _FeedbackCard();

  @override
  State<_FeedbackCard> createState() => _FeedbackCardState();
}

class _FeedbackCardState extends State<_FeedbackCard> {
  final _controller = TextEditingController();
  bool _isExpanded = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<FeedbackBloc, FeedbackState>(
      listener: (context, state) {
        if (state.status == FeedbackStatus.success) {
          _controller.clear();
          setState(() => _isExpanded = false);
          context.read<FeedbackBloc>().add(const FeedbackReset());
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('피드백이 전송되었습니다. 감사합니다!')),
          );
        } else if (state.status == FeedbackStatus.error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage ?? '전송에 실패했습니다.'),
            ),
          );
        }
      },
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: _cardDecoration(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 헤더 (탭으로 확장)
            InkWell(
              onTap: () => setState(() => _isExpanded = !_isExpanded),
              borderRadius: BorderRadius.circular(AppRadius.md),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: context.accentColor,
                      borderRadius: BorderRadius.circular(AppRadius.full),
                    ),
                    child: const Icon(
                      Icons.chat_bubble_outline,
                      color: AppColors.primary,
                      size: AppIconSize.xl,
                    ),
                  ),
                  AppSpacing.horizontalSm,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '운영진 피드백 보내기',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                        ),
                        Text(
                          '의견을 들려주세요',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: context.mutedForegroundColor,
                                  ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    _isExpanded
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    color: context.textTertiary,
                  ),
                ],
              ),
            ),

            // 확장 영역: 텍스트필드 + 버튼
            if (_isExpanded) ...[
              AppSpacing.verticalMd,
              TextField(
                controller: _controller,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: '불편하신 점이나 건의사항을 남겨주세요',
                  hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: context.mutedForegroundColor,
                      ),
                  filled: true,
                  fillColor: context.inputBgColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                    borderSide: BorderSide(color: context.borderColor),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                    borderSide: BorderSide(color: context.borderColor),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                    borderSide: const BorderSide(
                      color: AppColors.primary,
                      width: 1.5,
                    ),
                  ),
                  contentPadding: const EdgeInsets.all(AppSpacing.md),
                ),
              ),
              AppSpacing.verticalSm,
              BlocBuilder<FeedbackBloc, FeedbackState>(
                builder: (context, feedbackState) {
                  return Row(
                    children: [
                      // 취소 버튼
                      Expanded(
                        child: SizedBox(
                          height: 44,
                          child: TextButton(
                            onPressed: feedbackState.isSubmitting
                                ? null
                                : () {
                                    _controller.clear();
                                    setState(() => _isExpanded = false);
                                  },
                            style: TextButton.styleFrom(
                              backgroundColor: context.mutedColor,
                              foregroundColor: context.mutedForegroundColor,
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(AppRadius.sm),
                              ),
                            ),
                            child: const Text('취소'),
                          ),
                        ),
                      ),
                      AppSpacing.horizontalSm,
                      // 전송 버튼
                      Expanded(
                        child: SizedBox(
                          height: 44,
                          child: FilledButton(
                            onPressed: feedbackState.isSubmitting
                                ? null
                                : () {
                                    final content =
                                        _controller.text.trim();
                                    if (content.isEmpty) return;
                                    context.read<FeedbackBloc>().add(
                                          FeedbackSubmitted(
                                            category: 'general',
                                            content: content,
                                          ),
                                        );
                                  },
                            style: FilledButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(AppRadius.sm),
                              ),
                            ),
                            child: feedbackState.isSubmitting
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Text('전송'),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// 알림 설정 카드
// ─────────────────────────────────────────────────────────────

class _NotificationsCard extends StatelessWidget {
  final dynamic user;

  const _NotificationsCard({required this.user});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: _cardDecoration(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '알림 설정',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: context.textPrimary,
                  letterSpacing: 0.3,
                ),
          ),
          AppSpacing.verticalSm,
          _ToggleTile(
            icon: Icons.notifications_active_outlined,
            iconColor: AppColors.success,
            title: '푸시 알림',
            value: user?.pushEnabled ?? true,
            onChanged: (value) {
              context.read<UserBloc>().add(
                    UserNotificationSettingsUpdateRequested(
                      pushEnabled: value,
                    ),
                  );
            },
          ),
          Divider(height: 1, color: Theme.of(context).dividerColor),
          _ToggleTile(
            icon: Icons.campaign_outlined,
            iconColor: AppColors.primary,
            title: '브로드캐스트 알림',
            value: user?.broadcastPushEnabled ?? true,
            onChanged: (value) {
              context.read<UserBloc>().add(
                    UserNotificationSettingsUpdateRequested(
                      broadcastPushEnabled: value,
                    ),
                  );
            },
          ),
          Divider(height: 1, color: Theme.of(context).dividerColor),
          _ToggleTile(
            icon: Icons.chat_bubble_outline,
            iconColor: AppColors.info,
            title: '메시지 알림',
            value: user?.messagePushEnabled ?? true,
            onChanged: (value) {
              context.read<UserBloc>().add(
                    UserNotificationSettingsUpdateRequested(
                      messagePushEnabled: value,
                    ),
                  );
            },
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// 일반 설정 카드
// ─────────────────────────────────────────────────────────────

class _GeneralCard extends StatelessWidget {
  const _GeneralCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: _cardDecoration(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '일반',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: context.textPrimary,
                  letterSpacing: 0.3,
                ),
          ),
          AppSpacing.verticalSm,
          BlocBuilder<ThemeCubit, ThemeState>(
            builder: (context, themeState) {
              return _ToggleTile(
                icon: Icons.dark_mode_outlined,
                iconColor: context.textTertiary,
                title: '다크 모드',
                value: themeState.isDarkMode,
                onChanged: (value) {
                  context.read<ThemeCubit>().setThemeMode(
                        value ? ThemeMode.dark : ThemeMode.light,
                      );
                },
              );
            },
          ),
          Divider(height: 1, color: Theme.of(context).dividerColor),
          BlocBuilder<LocaleCubit, LocaleState>(
            builder: (context, localeState) {
              return _SettingsTile(
                icon: Icons.language_outlined,
                iconColor: context.textTertiary,
                title: '언어',
                trailing: Text(
                  localeState.displayName,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: context.textTertiary,
                      ),
                ),
                onTap: () => _showLanguageSelection(context),
              );
            },
          ),
        ],
      ),
    );
  }

  void _showLanguageSelection(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
      ),
      builder: (bottomSheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppSpacing.verticalSm,
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.neutral300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            AppSpacing.verticalMd,
            ListTile(
              title: const Text('한국어'),
              trailing: context
                          .read<LocaleCubit>()
                          .state
                          .locale
                          .languageCode ==
                      'ko'
                  ? Icon(Icons.check_rounded, color: AppColors.primary)
                  : null,
              onTap: () {
                context
                    .read<LocaleCubit>()
                    .setLocale(const Locale('ko', 'KR'));
                Navigator.pop(bottomSheetContext);
              },
            ),
            ListTile(
              title: const Text('English'),
              trailing: context
                          .read<LocaleCubit>()
                          .state
                          .locale
                          .languageCode ==
                      'en'
                  ? Icon(Icons.check_rounded, color: AppColors.primary)
                  : null,
              onTap: () {
                context
                    .read<LocaleCubit>()
                    .setLocale(const Locale('en', 'US'));
                Navigator.pop(bottomSheetContext);
              },
            ),
            AppSpacing.verticalSm,
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// 지원 카드
// ─────────────────────────────────────────────────────────────

class _SupportCard extends StatelessWidget {
  const _SupportCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: _cardDecoration(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '지원',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: context.textPrimary,
                  letterSpacing: 0.3,
                ),
          ),
          AppSpacing.verticalSm,
          _SettingsTile(
            icon: Icons.help_outline_rounded,
            iconColor: context.textTertiary,
            title: '도움말',
            onTap: () => context.push('/help'),
          ),
          Divider(height: 1, color: Theme.of(context).dividerColor),
          _SettingsTile(
            icon: Icons.policy_outlined,
            iconColor: context.textTertiary,
            title: '개인정보처리방침',
            onTap: () => context.push('/privacy-policy'),
          ),
          Divider(height: 1, color: Theme.of(context).dividerColor),
          _SettingsTile(
            icon: Icons.description_outlined,
            iconColor: context.textTertiary,
            title: '이용약관',
            onTap: () => context.push('/terms-of-service'),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// 앱 정보 카드
// ─────────────────────────────────────────────────────────────

class _AppInfoCard extends StatelessWidget {
  const _AppInfoCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: context.accentColor.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: Border.all(color: context.borderColor),
      ),
      child: Center(
        child: Text(
          '보이스팅 v1.0.0',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: context.mutedForegroundColor,
              ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// 공통 tile 위젯
// ─────────────────────────────────────────────────────────────

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _SettingsTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: iconColor, size: AppIconSize.lg),
      title: Text(title, style: Theme.of(context).textTheme.bodyLarge),
      trailing: trailing ??
          (onTap != null
              ? Icon(
                  Icons.chevron_right_rounded,
                  color: context.textTertiary,
                  size: AppIconSize.lg,
                )
              : null),
      onTap: onTap,
    );
  }
}

class _ToggleTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _ToggleTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: iconColor, size: AppIconSize.lg),
      title: Text(title, style: Theme.of(context).textTheme.bodyLarge),
      trailing: Switch.adaptive(
        value: value,
        onChanged: onChanged,
        activeTrackColor: AppColors.primary,
      ),
    );
  }
}
