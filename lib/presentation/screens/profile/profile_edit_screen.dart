import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:talk_flutter/core/constants/app_constants.dart';
import 'package:talk_flutter/core/theme/theme.dart';
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
  File? _selectedImage;
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
              profileImage: _selectedImage,
            ),
          );
    }
  }

  void _showImagePicker() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('카메라'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('갤러리'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: source,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 85,
    );
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('프로필 수정'),
        actions: [
          BlocBuilder<UserBloc, UserState>(
            builder: (context, state) {
              return TextButton(
                onPressed: state.isLoading ? null : _save,
                child: state.isLoading
                    ? SizedBox(
                        width: AppIconSize.md,
                        height: AppIconSize.md,
                        child: const CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('저장'),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: BlocConsumer<UserBloc, UserState>(
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
                  backgroundColor: colorScheme.error,
                ),
              );
            }
          },
          builder: (context, state) {
            return SingleChildScrollView(
              padding: AppSpacing.screenPadding,
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
                            radius: AppAvatarSize.hero,
                            backgroundColor: colorScheme.primaryContainer,
                            backgroundImage: _selectedImage != null
                                ? FileImage(_selectedImage!)
                                : (state.currentUser?.profileImageUrl != null
                                    ? NetworkImage(state.currentUser!.profileImageUrl!)
                                    : null),
                            child: (_selectedImage == null && state.currentUser?.profileImageUrl == null)
                                ? Icon(
                                    Icons.person,
                                    size: AppIconSize.hero,
                                    color: colorScheme.onPrimaryContainer,
                                  )
                                : null,
                          ),
                          Positioned(
                            right: 0,
                            bottom: 0,
                            child: CircleAvatar(
                              radius: 18,
                              backgroundColor: colorScheme.primary,
                              child: IconButton(
                                icon: Icon(
                                  Icons.camera_alt,
                                  size: AppIconSize.sm + 2,
                                ),
                                color: colorScheme.onPrimary,
                                onPressed: () => _showImagePicker(),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    AppSpacing.verticalXxl,

                    // Nickname
                    Text(
                      '닉네임',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    AppSpacing.verticalXs,
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
                    AppSpacing.verticalXl,

                    // Gender
                    Text(
                      '성별',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    AppSpacing.verticalXs,
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
                    AppSpacing.verticalXl,

                    // Phone number (read-only)
                    Text(
                      '전화번호',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    AppSpacing.verticalXs,
                    TextFormField(
                      initialValue: state.currentUser?.phoneNumber ?? '미등록',
                      readOnly: true,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.phone),
                        border: const OutlineInputBorder(),
                        fillColor: colorScheme.surfaceContainerHighest,
                        filled: true,
                      ),
                    ),
                    AppSpacing.verticalXs,
                    Text(
                      '전화번호는 변경할 수 없습니다.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
