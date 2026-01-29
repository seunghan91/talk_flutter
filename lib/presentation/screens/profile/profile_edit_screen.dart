import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:talk_flutter/core/constants/app_constants.dart';
import 'package:talk_flutter/presentation/blocs/user/user_bloc.dart';

/// Profile edit screen
class ProfileEditScreen extends StatefulWidget {
  const ProfileEditScreen({super.key});

  @override
  State<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nicknameController;
  late String _selectedGender;
  bool _isInitialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      final user = context.read<UserBloc>().state.currentUser;
      _nicknameController = TextEditingController(text: user?.nickname ?? '');
      _selectedGender = user?.gender.name ?? 'unknown';
      _isInitialized = true;
    }
  }

  @override
  void dispose() {
    _nicknameController.dispose();
    super.dispose();
  }

  void _save() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<UserBloc>().add(
            UserProfileUpdateRequested(
              nickname: _nicknameController.text.trim(),
              gender: _selectedGender,
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('프로필 수정'),
        actions: [
          BlocBuilder<UserBloc, UserState>(
            builder: (context, state) {
              return TextButton(
                onPressed: state.isLoading ? null : _save,
                child: state.isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('저장'),
              );
            },
          ),
        ],
      ),
      body: BlocConsumer<UserBloc, UserState>(
        listener: (context, state) {
          if (state.successMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.successMessage!)),
            );
            context.pop();
          } else if (state.hasError && state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage!),
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
            );
          }
        },
        builder: (context, state) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Profile image
                  Center(
                    child: Stack(
                      children: [
                        CircleAvatar(
                          radius: 60,
                          backgroundColor:
                              Theme.of(context).colorScheme.primaryContainer,
                          backgroundImage: state.currentUser?.profileImageUrl != null
                              ? NetworkImage(state.currentUser!.profileImageUrl!)
                              : null,
                          child: state.currentUser?.profileImageUrl == null
                              ? Icon(
                                  Icons.person,
                                  size: 60,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onPrimaryContainer,
                                )
                              : null,
                        ),
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: CircleAvatar(
                            radius: 18,
                            backgroundColor: Theme.of(context).colorScheme.primary,
                            child: IconButton(
                              icon: const Icon(Icons.camera_alt, size: 18),
                              color: Theme.of(context).colorScheme.onPrimary,
                              onPressed: () {
                                // TODO: Image picker
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('프로필 사진 변경 기능 준비 중'),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Nickname
                  Text(
                    '닉네임',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _nicknameController,
                    maxLength: AppConstants.maxNicknameLength,
                    decoration: const InputDecoration(
                      hintText: '닉네임을 입력하세요',
                      prefixIcon: Icon(Icons.person),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return '닉네임을 입력해주세요';
                      }
                      if (value.trim().length < 2) {
                        return '닉네임은 2자 이상이어야 합니다';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),

                  // Gender
                  Text(
                    '성별',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    initialValue: _selectedGender,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.wc),
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'unknown', child: Text('선택 안함')),
                      DropdownMenuItem(value: 'male', child: Text('남성')),
                      DropdownMenuItem(value: 'female', child: Text('여성')),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _selectedGender = value);
                      }
                    },
                  ),
                  const SizedBox(height: 24),

                  // Phone number (read-only)
                  Text(
                    '전화번호',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    initialValue: state.currentUser?.phoneNumber ?? '미등록',
                    readOnly: true,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.phone),
                      border: const OutlineInputBorder(),
                      fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                      filled: true,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '전화번호는 변경할 수 없습니다.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
