import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:talk_flutter/presentation/blocs/auth/auth_bloc.dart';
import 'package:talk_flutter/presentation/blocs/user/user_bloc.dart';

/// Settings screen
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('설정'),
      ),
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          return ListView(
            children: [
              // Profile section
              _ProfileHeader(
                nickname: state.user?.nickname ?? 'User',
                phoneNumber: state.user?.phoneNumber ?? '',
                onTap: () {
                  context.push('/settings/profile');
                },
              ),

              const Divider(),

              // Account section
              _SettingsSection(
                title: '계정',
                children: [
                  _SettingsTile(
                    icon: Icons.account_balance_wallet_outlined,
                    title: '지갑',
                    subtitle: '잔액 및 거래 내역',
                    onTap: () => context.push('/wallet'),
                  ),
                  _SettingsTile(
                    icon: Icons.notifications_outlined,
                    title: '알림',
                    subtitle: '알림 목록 보기',
                    onTap: () => context.push('/notifications'),
                  ),
                ],
              ),

              const Divider(),

              // Notification settings
              _SettingsSection(
                title: '알림 설정',
                children: [
                  _SettingsTile(
                    icon: Icons.notifications_active_outlined,
                    title: '푸시 알림',
                    subtitle: '모든 알림 받기',
                    trailing: Switch(
                      value: state.user?.pushEnabled ?? true,
                      onChanged: (value) {
                        context.read<UserBloc>().add(
                              UserNotificationSettingsUpdateRequested(
                                pushEnabled: value,
                              ),
                            );
                      },
                    ),
                  ),
                  _SettingsTile(
                    icon: Icons.campaign_outlined,
                    title: '브로드캐스트 알림',
                    subtitle: '새 브로드캐스트 알림 받기',
                    trailing: Switch(
                      value: state.user?.broadcastPushEnabled ?? true,
                      onChanged: (value) {
                        context.read<UserBloc>().add(
                              UserNotificationSettingsUpdateRequested(
                                broadcastPushEnabled: value,
                              ),
                            );
                      },
                    ),
                  ),
                  _SettingsTile(
                    icon: Icons.chat_bubble_outline,
                    title: '메시지 알림',
                    subtitle: '새 메시지 알림 받기',
                    trailing: Switch(
                      value: state.user?.messagePushEnabled ?? true,
                      onChanged: (value) {
                        context.read<UserBloc>().add(
                              UserNotificationSettingsUpdateRequested(
                                messagePushEnabled: value,
                              ),
                            );
                      },
                    ),
                  ),
                ],
              ),

              const Divider(),

              // App settings
              _SettingsSection(
                title: '앱 설정',
                children: [
                  _SettingsTile(
                    icon: Icons.dark_mode_outlined,
                    title: '다크 모드',
                    subtitle: '어두운 테마 사용',
                    trailing: Switch(
                      value: false, // TODO: Get from theme settings
                      onChanged: (value) {
                        // TODO: Toggle dark mode
                      },
                    ),
                  ),
                  _SettingsTile(
                    icon: Icons.language_outlined,
                    title: '언어',
                    subtitle: '한국어',
                    onTap: () {
                      // TODO: Language selection
                    },
                  ),
                ],
              ),

              const Divider(),

              // Support section
              _SettingsSection(
                title: '지원',
                children: [
                  _SettingsTile(
                    icon: Icons.help_outline,
                    title: '도움말',
                    onTap: () {
                      // TODO: Help page
                    },
                  ),
                  _SettingsTile(
                    icon: Icons.policy_outlined,
                    title: '개인정보처리방침',
                    onTap: () {
                      // TODO: Privacy policy
                    },
                  ),
                  _SettingsTile(
                    icon: Icons.description_outlined,
                    title: '이용약관',
                    onTap: () {
                      // TODO: Terms of service
                    },
                  ),
                  _SettingsTile(
                    icon: Icons.info_outline,
                    title: '앱 버전',
                    subtitle: '1.0.0',
                  ),
                ],
              ),

              const Divider(),

              // Logout
              Padding(
                padding: const EdgeInsets.all(16),
                child: OutlinedButton(
                  onPressed: () {
                    _showLogoutDialog(context);
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Theme.of(context).colorScheme.error,
                    side: BorderSide(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                  child: const Text('로그아웃'),
                ),
              ),

              const SizedBox(height: 32),
            ],
          );
        },
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('로그아웃'),
        content: const Text('정말 로그아웃 하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<AuthBloc>().add(const AuthLogoutRequested());
            },
            child: Text(
              '로그아웃',
              style: TextStyle(
                color: Theme.of(context).colorScheme.error,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  final String nickname;
  final String phoneNumber;
  final VoidCallback onTap;

  const _ProfileHeader({
    required this.nickname,
    required this.phoneNumber,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.all(16),
      leading: CircleAvatar(
        radius: 32,
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        child: Text(
          nickname.isNotEmpty ? nickname[0].toUpperCase() : 'U',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onPrimaryContainer,
          ),
        ),
      ),
      title: Text(
        nickname,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
      ),
      subtitle: Text(phoneNumber),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}

class _SettingsSection extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _SettingsSection({
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),
        ...children,
      ],
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: subtitle != null ? Text(subtitle!) : null,
      trailing: trailing ?? (onTap != null ? const Icon(Icons.chevron_right) : null),
      onTap: onTap,
    );
  }
}
