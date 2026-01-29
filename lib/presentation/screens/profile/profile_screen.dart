import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:talk_flutter/core/enums/app_enums.dart';
import 'package:talk_flutter/presentation/blocs/auth/auth_bloc.dart';
import 'package:talk_flutter/presentation/blocs/user/user_bloc.dart';

/// Profile screen - displays and edits user profile
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
      appBar: AppBar(
        title: const Text('프로필'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => context.push('/profile/edit'),
            tooltip: '프로필 수정',
          ),
        ],
      ),
      body: BlocConsumer<UserBloc, UserState>(
        listener: (context, state) {
          if (state.hasError && state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage!),
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state.isLoading && state.currentUser == null) {
            return const Center(child: CircularProgressIndicator());
          }

          final user = state.currentUser;
          if (user == null) {
            return const Center(child: Text('프로필 정보를 불러올 수 없습니다.'));
          }

          return RefreshIndicator(
            onRefresh: () async {
              context.read<UserBloc>().add(const UserProfileRequested());
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Profile header
                  _ProfileHeader(user: user),
                  const SizedBox(height: 24),

                  // Profile info cards
                  _InfoCard(
                    title: '기본 정보',
                    children: [
                      _InfoRow(
                        icon: Icons.person,
                        label: '닉네임',
                        value: user.nickname,
                      ),
                      _InfoRow(
                        icon: Icons.phone,
                        label: '전화번호',
                        value: user.phoneNumber ?? '미등록',
                      ),
                      _InfoRow(
                        icon: Icons.wc,
                        label: '성별',
                        value: _genderText(user.gender),
                      ),
                      _InfoRow(
                        icon: Icons.calendar_today,
                        label: '가입일',
                        value: _formatDate(user.createdAt),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Notification settings
                  _InfoCard(
                    title: '알림 설정',
                    trailing: TextButton(
                      onPressed: () => _showNotificationSettings(context, state),
                      child: const Text('변경'),
                    ),
                    children: [
                      _InfoRow(
                        icon: Icons.notifications,
                        label: '푸시 알림',
                        value: user.pushEnabled ? '켜짐' : '꺼짐',
                      ),
                      _InfoRow(
                        icon: Icons.campaign,
                        label: '브로드캐스트 알림',
                        value: user.broadcastPushEnabled ? '켜짐' : '꺼짐',
                      ),
                      _InfoRow(
                        icon: Icons.message,
                        label: '메시지 알림',
                        value: user.messagePushEnabled ? '켜짐' : '꺼짐',
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Account actions
                  _InfoCard(
                    title: '계정',
                    children: [
                      ListTile(
                        leading: const Icon(Icons.lock),
                        title: const Text('비밀번호 변경'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => _showChangePasswordDialog(context),
                      ),
                      ListTile(
                        leading: const Icon(Icons.block),
                        title: const Text('차단 목록'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => _showBlockedUsers(context),
                      ),
                      ListTile(
                        leading: Icon(
                          Icons.logout,
                          color: Theme.of(context).colorScheme.error,
                        ),
                        title: Text(
                          '로그아웃',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                          ),
                        ),
                        onTap: () => _confirmLogout(context),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
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
    bool pushEnabled = state.notificationSettings['push_enabled'] ?? true;
    bool broadcastPushEnabled = state.notificationSettings['broadcast_push_enabled'] ?? true;
    bool messagePushEnabled = state.notificationSettings['message_push_enabled'] ?? true;

    showModalBottomSheet(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '알림 설정',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                SwitchListTile(
                  title: const Text('푸시 알림'),
                  subtitle: const Text('모든 푸시 알림을 켜거나 끕니다'),
                  value: pushEnabled,
                  onChanged: (value) {
                    setModalState(() => pushEnabled = value);
                  },
                ),
                SwitchListTile(
                  title: const Text('브로드캐스트 알림'),
                  subtitle: const Text('새 브로드캐스트 수신 시 알림'),
                  value: broadcastPushEnabled,
                  onChanged: pushEnabled
                      ? (value) {
                          setModalState(() => broadcastPushEnabled = value);
                        }
                      : null,
                ),
                SwitchListTile(
                  title: const Text('메시지 알림'),
                  subtitle: const Text('새 메시지 수신 시 알림'),
                  value: messagePushEnabled,
                  onChanged: pushEnabled
                      ? (value) {
                          setModalState(() => messagePushEnabled = value);
                        }
                      : null,
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
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
        title: const Text('비밀번호 변경'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: currentPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: '현재 비밀번호',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: newPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: '새 비밀번호',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: confirmPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: '비밀번호 확인',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          FilledButton(
            onPressed: () {
              if (newPasswordController.text != confirmPasswordController.text) {
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
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '차단 목록',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                  ),
                  const Divider(),
                  if (state.isLoading)
                    const Expanded(
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else if (state.blockedUsers.isEmpty)
                    const Expanded(
                      child: Center(child: Text('차단한 사용자가 없습니다.')),
                    )
                  else
                    Expanded(
                      child: ListView.builder(
                        controller: scrollController,
                        itemCount: state.blockedUsers.length,
                        itemBuilder: (context, index) {
                          final blockedUser = state.blockedUsers[index];
                          return ListTile(
                            leading: CircleAvatar(
                              child: Text(blockedUser.nickname[0]),
                            ),
                            title: Text(blockedUser.nickname),
                            trailing: TextButton(
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
        title: const Text('로그아웃'),
        content: const Text('정말 로그아웃하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          FilledButton(
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

class _ProfileHeader extends StatelessWidget {
  final dynamic user;

  const _ProfileHeader({required this.user});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          radius: 50,
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          backgroundImage: user.profileImageUrl != null
              ? NetworkImage(user.profileImageUrl!)
              : null,
          child: user.profileImageUrl == null
              ? Text(
                  user.nickname.isNotEmpty ? user.nickname[0].toUpperCase() : '?',
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                )
              : null,
        ),
        const SizedBox(height: 12),
        Text(
          user.nickname,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        if (user.verified)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.verified,
                size: 16,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 4),
              Text(
                '인증됨',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                    ),
              ),
            ],
          ),
      ],
    );
  }
}

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
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                if (trailing != null) trailing!,
              ],
            ),
          ),
          ...children,
        ],
      ),
    );
  }
}

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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Theme.of(context).colorScheme.onSurfaceVariant),
          const SizedBox(width: 12),
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}
