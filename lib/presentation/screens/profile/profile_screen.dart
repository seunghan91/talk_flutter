import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:talk_flutter/core/enums/app_enums.dart';
import 'package:talk_flutter/core/theme/theme.dart';
import 'package:talk_flutter/presentation/blocs/auth/auth_bloc.dart';
import 'package:talk_flutter/presentation/blocs/user/user_bloc.dart';

/// Profile screen - displays user profile with design system styling
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    context.read<UserBloc>().add(const UserProfileRequested());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Column(
          children: [
            // Custom header
            _buildHeader(),

            // Body
            Expanded(
              child: BlocConsumer<UserBloc, UserState>(
                listener: (context, state) {
                  if (state.hasError && state.errorMessage != null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(state.errorMessage!),
                        backgroundColor: AppColors.primary,
                      ),
                    );
                  }
                },
                builder: (context, state) {
                  if (state.isLoading && state.currentUser == null) {
                    return const Center(
                      child:
                          CircularProgressIndicator(color: AppColors.primary),
                    );
                  }

                  final user = state.currentUser;
                  if (user == null) {
                    return Center(
                      child: Text(
                        '프로필 정보를 불러올 수 없습니다.',
                        style: TextStyle(color: context.mutedForegroundColor),
                      ),
                    );
                  }

                  return RefreshIndicator(
                    color: AppColors.primary,
                    onRefresh: () async {
                      context
                          .read<UserBloc>()
                          .add(const UserProfileRequested());
                    },
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(AppSpacing.md),
                      child: Column(
                        children: [
                          AppSpacing.verticalSm,

                          // Profile card (avatar + nickname + badge)
                          _ProfileCard(user: user),
                          AppSpacing.verticalMd,

                          // Info card: nickname, gender, phone
                          _InfoCard(
                            title: '기본 정보',
                            children: [
                              _InfoRow(
                                icon: Icons.person_outline_rounded,
                                label: '닉네임',
                                value: user.nickname,
                              ),
                              const _Divider(),
                              _InfoRow(
                                icon: Icons.phone_outlined,
                                label: '전화번호',
                                value: user.phoneNumber ?? '미등록',
                              ),
                              const _Divider(),
                              _InfoRow(
                                icon: Icons.wc_rounded,
                                label: '성별',
                                value: _genderText(user.gender),
                              ),
                              const _Divider(),
                              _InfoRow(
                                icon: Icons.calendar_today_outlined,
                                label: '가입일',
                                value: _formatDate(user.createdAt),
                              ),
                            ],
                          ),
                          AppSpacing.verticalMd,

                          // Notification settings card
                          _InfoCard(
                            title: '알림 설정',
                            trailing: GestureDetector(
                              onTap: () =>
                                  _showNotificationSettings(context, state),
                              child: const Text(
                                '변경',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            children: [
                              _InfoRow(
                                icon: Icons.notifications_outlined,
                                label: '푸시 알림',
                                value: user.pushEnabled ? '켜짐' : '꺼짐',
                              ),
                              const _Divider(),
                              _InfoRow(
                                icon: Icons.campaign_outlined,
                                label: '보이스팅 알림',
                                value: user.broadcastPushEnabled ? '켜짐' : '꺼짐',
                              ),
                              const _Divider(),
                              _InfoRow(
                                icon: Icons.message_outlined,
                                label: '메시지 알림',
                                value: user.messagePushEnabled ? '켜짐' : '꺼짐',
                              ),
                            ],
                          ),
                          AppSpacing.verticalMd,

                          // Account card
                          _InfoCard(
                            title: '계정',
                            children: [
                              _TappableRow(
                                icon: Icons.lock_outline_rounded,
                                label: '비밀번호 변경',
                                onTap: () =>
                                    _showChangePasswordDialog(context),
                              ),
                              const _Divider(),
                              _TappableRow(
                                icon: Icons.block_rounded,
                                label: '차단 목록',
                                onTap: () => _showBlockedUsers(context),
                              ),
                              const _Divider(),
                              _TappableRow(
                                icon: Icons.logout_rounded,
                                label: '로그아웃',
                                foregroundColor: AppColors.primary,
                                onTap: () => _confirmLogout(context),
                              ),
                            ],
                          ),

                          AppSpacing.verticalXxl,
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: context.cardColor,
        border: Border(
          bottom: BorderSide(color: context.borderColor, width: 1),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, size: 18),
            color: context.textPrimary,
            onPressed: () => context.pop(),
          ),
          Expanded(
            child: Center(
              child: Text(
                '프로필',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: context.textPrimary,
                ),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.edit_outlined, size: 20),
            color: AppColors.primary,
            onPressed: () => context.push('/profile/edit'),
            tooltip: '프로필 수정',
          ),
        ],
      ),
    );
  }

  String _genderText(Gender gender) {
    switch (gender) {
      case Gender.male:
        return '남성';
      case Gender.female:
        return '여성';
      default:
        return '미지정';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')}';
  }

  void _showNotificationSettings(BuildContext context, UserState state) {
    bool pushEnabled =
        state.notificationSettings['push_enabled'] ?? true;
    bool broadcastPushEnabled =
        state.notificationSettings['broadcast_push_enabled'] ?? true;
    bool messagePushEnabled =
        state.notificationSettings['message_push_enabled'] ?? true;

    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.bottomSheetRadius,
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          return Padding(
            padding: AppSpacing.screenPadding,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '알림 설정',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: context.textPrimary,
                  ),
                ),
                AppSpacing.verticalMd,
                SwitchListTile(
                  activeTrackColor: AppColors.primary,
                  title: const Text('푸시 알림'),
                  subtitle: const Text('모든 푸시 알림을 켜거나 끕니다'),
                  value: pushEnabled,
                  onChanged: (value) {
                    setModalState(() => pushEnabled = value);
                  },
                ),
                SwitchListTile(
                  activeTrackColor: AppColors.primary,
                  title: const Text('보이스팅 알림'),
                  subtitle: const Text('새 보이스팅 수신 시 알림'),
                  value: broadcastPushEnabled,
                  onChanged: pushEnabled
                      ? (value) {
                          setModalState(() => broadcastPushEnabled = value);
                        }
                      : null,
                ),
                SwitchListTile(
                  activeTrackColor: AppColors.primary,
                  title: const Text('메시지 알림'),
                  subtitle: const Text('새 메시지 수신 시 알림'),
                  value: messagePushEnabled,
                  onChanged: pushEnabled
                      ? (value) {
                          setModalState(() => messagePushEnabled = value);
                        }
                      : null,
                ),
                AppSpacing.verticalMd,
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                      ),
                    ),
                    onPressed: () {
                      context.read<UserBloc>().add(
                            UserNotificationSettingsUpdateRequested(
                              pushEnabled: pushEnabled,
                              broadcastPushEnabled: broadcastPushEnabled,
                              messagePushEnabled: messagePushEnabled,
                            ),
                          );
                      Navigator.pop(context);
                    },
                    child: const Text('저장'),
                  ),
                ),
                AppSpacing.verticalMd,
              ],
            ),
          );
        },
      ),
    );
  }

  void _showChangePasswordDialog(BuildContext context) {
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        title: const Text('비밀번호 변경'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _StyledTextField(
              controller: currentPasswordController,
              labelText: '현재 비밀번호',
              obscureText: true,
            ),
            AppSpacing.verticalSm,
            _StyledTextField(
              controller: newPasswordController,
              labelText: '새 비밀번호',
              obscureText: true,
            ),
            AppSpacing.verticalSm,
            _StyledTextField(
              controller: confirmPasswordController,
              labelText: '비밀번호 확인',
              obscureText: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('취소',
                style: TextStyle(color: context.mutedForegroundColor)),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
            ),
            onPressed: () {
              if (newPasswordController.text !=
                  confirmPasswordController.text) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('비밀번호가 일치하지 않습니다.')),
                );
                return;
              }
              context.read<UserBloc>().add(
                    UserPasswordChangeRequested(
                      currentPassword: currentPasswordController.text,
                      newPassword: newPasswordController.text,
                    ),
                  );
              Navigator.pop(context);
            },
            child: const Text('변경'),
          ),
        ],
      ),
    );
  }

  void _showBlockedUsers(BuildContext context) {
    context.read<UserBloc>().add(const UserBlockedListRequested());

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.bottomSheetRadius,
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.3,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) {
          return BlocBuilder<UserBloc, UserState>(
            builder: (context, state) {
              return Column(
                children: [
                  Padding(
                    padding: AppSpacing.screenPadding,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '차단 목록',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: context.textPrimary,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                  ),
                  Divider(height: 1, color: context.borderColor),
                  if (state.isLoading)
                    const Expanded(
                      child: Center(
                        child: CircularProgressIndicator(
                            color: AppColors.primary),
                      ),
                    )
                  else if (state.blockedUsers.isEmpty)
                    Expanded(
                      child: Center(
                        child: Text(
                          '차단한 사용자가 없습니다.',
                          style: TextStyle(color: context.mutedForegroundColor),
                        ),
                      ),
                    )
                  else
                    Expanded(
                      child: ListView.separated(
                        controller: scrollController,
                        itemCount: state.blockedUsers.length,
                        separatorBuilder: (context, index) =>
                            Divider(height: 1, color: context.borderColor),
                        itemBuilder: (context, index) {
                          final blockedUser = state.blockedUsers[index];
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundColor:
                                  AppColors.primary.withValues(alpha: 0.12),
                              child: Text(
                                blockedUser.nickname[0].toUpperCase(),
                                style: const TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            title: Text(blockedUser.nickname),
                            trailing: TextButton(
                              style: TextButton.styleFrom(
                                foregroundColor: AppColors.primary,
                              ),
                              onPressed: () {
                                context.read<UserBloc>().add(
                                      UserUnblockRequested(
                                        userId: blockedUser.id,
                                      ),
                                    );
                              },
                              child: const Text('차단 해제'),
                            ),
                          );
                        },
                      ),
                    ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        title: const Text('로그아웃'),
        content: const Text('정말 로그아웃하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('취소',
                style: TextStyle(color: context.mutedForegroundColor)),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
            ),
            onPressed: () {
              context.read<AuthBloc>().add(const AuthLogoutRequested());
              context.read<UserBloc>().add(const UserCleared());
              Navigator.pop(context);
            },
            child: const Text('로그아웃'),
          ),
        ],
      ),
    );
  }
}

// ─── Profile card ─────────────────────────────────────────────────────────────

class _ProfileCard extends StatelessWidget {
  final dynamic user;

  const _ProfileCard({required this.user});

  @override
  Widget build(BuildContext context) {
    final nickname = (user.nickname as String?) ?? '';
    final initial =
        nickname.isNotEmpty ? nickname[0].toUpperCase() : '?';
    final genderLabel = _genderLabel(user.gender);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.xl),
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
      child: Column(
        children: [
          // Avatar
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: user.profileImageUrl != null
                ? ClipOval(
                    child: Image.network(
                      user.profileImageUrl!,
                      fit: BoxFit.cover,
                    ),
                  )
                : Center(
                    child: Text(
                      initial,
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
          ),
          AppSpacing.verticalSm,

          // Nickname
          Text(
            nickname.isNotEmpty ? nickname : '닉네임 없음',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: context.textPrimary,
            ),
          ),

          AppSpacing.verticalXxs,

          // Gender badge + verified
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (genderLabel.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(AppRadius.full),
                  ),
                  child: Text(
                    genderLabel,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: context.textPrimary,
                    ),
                  ),
                ),
              if (user.verified && genderLabel.isNotEmpty)
                AppSpacing.horizontalXs,
              if (user.verified)
                const Row(
                  children: [
                    Icon(Icons.verified_rounded,
                        size: 14, color: AppColors.primary),
                    SizedBox(width: 2),
                    Text(
                      '인증됨',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ],
      ),
    );
  }

  String _genderLabel(Gender gender) {
    switch (gender) {
      case Gender.male:
        return '남성';
      case Gender.female:
        return '여성';
      default:
        return '';
    }
  }
}

// ─── Info card ────────────────────────────────────────────────────────────────

class _InfoCard extends StatelessWidget {
  final String title;
  final Widget? trailing;
  final List<Widget> children;

  const _InfoCard({
    required this.title,
    this.trailing,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.md,
              AppSpacing.md,
              AppSpacing.xs,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: context.mutedForegroundColor,
                  ),
                ),
                if (trailing != null) trailing!,
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Divider(height: 1, color: context.borderColor),
          ),
          ...children,
          AppSpacing.verticalXs,
        ],
      ),
    );
  }
}

// ─── Info row ─────────────────────────────────────────────────────────────────

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        children: [
          Icon(icon, size: AppIconSize.md, color: context.mutedForegroundColor),
          AppSpacing.horizontalSm,
          SizedBox(
            width: 72,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: context.mutedForegroundColor,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 13,
                color: context.textPrimary,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Tappable row ─────────────────────────────────────────────────────────────

class _TappableRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? foregroundColor;
  final VoidCallback onTap;

  const _TappableRow({
    required this.icon,
    required this.label,
    this.foregroundColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = foregroundColor ?? context.textPrimary;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.sm),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        child: Row(
          children: [
            Icon(icon, size: AppIconSize.md, color: color),
            AppSpacing.horizontalSm,
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  color: color,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Icon(Icons.chevron_right_rounded,
                size: AppIconSize.md, color: context.mutedForegroundColor),
          ],
        ),
      ),
    );
  }
}

// ─── Divider ─────────────────────────────────────────────────────────────────

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Divider(height: 1, color: context.borderColor),
    );
  }
}

// ─── Styled text field ────────────────────────────────────────────────────────

class _StyledTextField extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final bool obscureText;

  const _StyledTextField({
    required this.controller,
    required this.labelText,
    this.obscureText = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      style: TextStyle(
        fontSize: 14,
        color: context.textPrimary,
      ),
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: TextStyle(color: context.mutedForegroundColor),
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
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
      ),
    );
  }
}
