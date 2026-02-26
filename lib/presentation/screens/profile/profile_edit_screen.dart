import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:talk_flutter/core/constants/app_constants.dart';
import 'package:talk_flutter/core/theme/theme.dart';
import 'package:talk_flutter/core/utils/nickname_generator.dart';
import 'package:talk_flutter/domain/entities/user.dart';
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
      final user = context.read<UserBloc>().state.currentUser;
      final canChangeNickname = user?.canChangeNickname ?? true;
      context.read<UserBloc>().add(
            UserProfileUpdateRequested(
              nickname: canChangeNickname
                  ? _nicknameController.text.trim()
                  : null,
              gender: _selectedGender,
              profileImage: _selectedImage,
            ),
          );
    }
  }

  void _showImagePicker() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.bottomSheetRadius,
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined,
                  color: AppColors.primary),
              title: const Text('카메라'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined,
                  color: AppColors.primary),
              title: const Text('갤러리'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
            AppSpacing.verticalMd,
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
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: _buildAppBar(),
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
                  backgroundColor: AppColors.primary,
                ),
              );
            }
          },
          builder: (context, state) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppSpacing.verticalSm,

                    // Form card
                    _FormCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Avatar picker
                          Center(
                            child: _AvatarPicker(
                              selectedImage: _selectedImage,
                              profileImageUrl:
                                  state.currentUser?.profileImageUrl,
                              nickname: state.currentUser?.nickname ?? '',
                              onTap: _showImagePicker,
                            ),
                          ),
                          AppSpacing.verticalXl,

                          // Nickname field
                          const _FieldLabel('닉네임'),
                          AppSpacing.verticalXs,
                          _NicknameSection(
                            controller: _nicknameController,
                            maxLength: AppConstants.maxNicknameLength,
                            user: state.currentUser,
                            onGenerate: () {
                              setState(() {
                                _nicknameController.text =
                                    NicknameGenerator.generate();
                              });
                            },
                          ),
                          AppSpacing.verticalXl,

                          // Gender selector
                          const _FieldLabel('성별'),
                          AppSpacing.verticalSm,
                          _GenderSelector(
                            selectedGender: _selectedGender,
                            onChanged: (value) =>
                                setState(() => _selectedGender = value),
                          ),
                          AppSpacing.verticalXl,

                          // Phone number (read-only)
                          const _FieldLabel('전화번호'),
                          AppSpacing.verticalXs,
                          _ReadOnlyField(
                            value: state.currentUser?.phoneNumber ?? '미등록',
                          ),
                          AppSpacing.verticalXxs,
                          Text(
                            '전화번호는 변경할 수 없습니다.',
                            style: TextStyle(
                              fontSize: 12,
                              color: context.mutedForegroundColor,
                            ),
                          ),
                        ],
                      ),
                    ),

                    AppSpacing.verticalMd,

                    // Action buttons
                    BlocBuilder<UserBloc, UserState>(
                      builder: (context, state) {
                        return Column(
                          children: [
                            // Save button
                            SizedBox(
                              width: double.infinity,
                              child: FilledButton(
                                style: FilledButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 14),
                                  shape: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.circular(AppRadius.sm),
                                  ),
                                ),
                                onPressed:
                                    state.isLoading ? null : _save,
                                child: state.isLoading
                                    ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                    : const Text(
                                        '저장',
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                              ),
                            ),
                            AppSpacing.verticalSm,
                            // Cancel button
                            SizedBox(
                              width: double.infinity,
                              child: TextButton(
                                style: TextButton.styleFrom(
                                  backgroundColor: context.mutedColor,
                                  foregroundColor: context.mutedForegroundColor,
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 14),
                                  shape: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.circular(AppRadius.sm),
                                  ),
                                ),
                                onPressed: () => context.pop(),
                                child: const Text(
                                  '취소',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),

                    AppSpacing.verticalXxl,
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return PreferredSize(
      preferredSize: const Size.fromHeight(56),
      child: Container(
        decoration: BoxDecoration(
          color: context.cardColor,
          border: Border(
            bottom: BorderSide(color: context.borderColor, width: 1),
          ),
        ),
        child: SafeArea(
          bottom: false,
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
                    '프로필 수정',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: context.textPrimary,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 48),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Form card ────────────────────────────────────────────────────────────────

class _FormCard extends StatelessWidget {
  final Widget child;

  const _FormCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
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

// ─── Avatar picker ────────────────────────────────────────────────────────────

class _AvatarPicker extends StatelessWidget {
  final File? selectedImage;
  final String? profileImageUrl;
  final String nickname;
  final VoidCallback onTap;

  const _AvatarPicker({
    required this.selectedImage,
    required this.profileImageUrl,
    required this.nickname,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final initial =
        nickname.isNotEmpty ? nickname[0].toUpperCase() : '?';

    return Stack(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: selectedImage != null
              ? ClipOval(child: Image.file(selectedImage!, fit: BoxFit.cover))
              : profileImageUrl != null
                  ? ClipOval(
                      child:
                          Image.network(profileImageUrl!, fit: BoxFit.cover))
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
        Positioned(
          right: 0,
          bottom: 0,
          child: GestureDetector(
            onTap: onTap,
            child: Container(
              width: 28,
              height: 28,
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.camera_alt_rounded,
                color: Colors.white,
                size: 14,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Field label ──────────────────────────────────────────────────────────────

class _FieldLabel extends StatelessWidget {
  final String text;

  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: context.textPrimary,
      ),
    );
  }
}

// ─── Nickname section (field + generate button + 30-day restriction) ──────────

class _NicknameSection extends StatelessWidget {
  final TextEditingController controller;
  final int maxLength;
  final User? user;
  final VoidCallback onGenerate;

  const _NicknameSection({
    required this.controller,
    required this.maxLength,
    required this.user,
    required this.onGenerate,
  });

  @override
  Widget build(BuildContext context) {
    final canChange = user?.canChangeNickname ?? true;
    final daysLeft = user?.daysUntilNicknameChange ?? 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _NicknameField(
                controller: controller,
                maxLength: maxLength,
                enabled: canChange,
              ),
            ),
            if (canChange) ...[
              AppSpacing.horizontalSm,
              SizedBox(
                height: 48,
                child: OutlinedButton(
                  onPressed: onGenerate,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.primary),
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                  ),
                  child: const Icon(Icons.refresh_rounded, size: 20),
                ),
              ),
            ],
          ],
        ),
        AppSpacing.verticalXs,
        if (!canChange)
          Row(
            children: [
              const Icon(Icons.lock_outline_rounded,
                  size: 13, color: AppColors.primary),
              const SizedBox(width: 4),
              Text(
                '$daysLeft일 후에 변경할 수 있어요',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          )
        else
          Text(
            '한 달에 한 번만 변경할 수 있어요',
            style: TextStyle(
              fontSize: 12,
              color: context.mutedForegroundColor,
            ),
          ),
      ],
    );
  }
}

class _NicknameField extends StatefulWidget {
  final TextEditingController controller;
  final int maxLength;
  final bool enabled;

  const _NicknameField({
    required this.controller,
    required this.maxLength,
    this.enabled = true,
  });

  @override
  State<_NicknameField> createState() => _NicknameFieldState();
}

class _NicknameFieldState extends State<_NicknameField> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(() => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    final isEnabled = widget.enabled;

    return TextFormField(
      controller: widget.controller,
      maxLength: widget.maxLength,
      enabled: isEnabled,
      buildCounter: (_,
              {required currentLength, required isFocused, maxLength}) =>
          Text(
        '$currentLength/$maxLength',
        style: TextStyle(
          fontSize: 11,
          color: context.mutedForegroundColor,
        ),
      ),
      style: TextStyle(
        fontSize: 14,
        color: isEnabled ? context.textPrimary : context.mutedForegroundColor,
      ),
      decoration: InputDecoration(
        hintText: '닉네임을 입력하세요',
        hintStyle: TextStyle(
          color: context.mutedForegroundColor,
          fontSize: 14,
        ),
        filled: true,
        fillColor: isEnabled ? context.inputBgColor : context.mutedColor,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
          borderSide: BorderSide(color: context.borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
          borderSide: BorderSide(color: context.borderColor),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
          borderSide: BorderSide(color: context.borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
          borderSide: const BorderSide(color: AppColors.primary),
        ),
      ),
      validator: (value) {
        if (!isEnabled) return null;
        if (value == null || value.trim().isEmpty) {
          return '닉네임을 입력해주세요';
        }
        if (value.trim().length < 2) {
          return '닉네임은 2자 이상이어야 합니다';
        }
        return null;
      },
    );
  }
}

// ─── Gender selector ──────────────────────────────────────────────────────────

class _GenderSelector extends StatelessWidget {
  final String selectedGender;
  final ValueChanged<String> onChanged;

  const _GenderSelector({
    required this.selectedGender,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _GenderButton(
            label: '여성',
            icon: Icons.female_rounded,
            value: 'female',
            selectedGender: selectedGender,
            onTap: () => onChanged('female'),
          ),
        ),
        AppSpacing.horizontalSm,
        Expanded(
          child: _GenderButton(
            label: '남성',
            icon: Icons.male_rounded,
            value: 'male',
            selectedGender: selectedGender,
            onTap: () => onChanged('male'),
          ),
        ),
        AppSpacing.horizontalSm,
        Expanded(
          child: _GenderButton(
            label: '미선택',
            icon: Icons.person_outline_rounded,
            value: 'unknown',
            selectedGender: selectedGender,
            onTap: () => onChanged('unknown'),
          ),
        ),
      ],
    );
  }
}

class _GenderButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final String value;
  final String selectedGender;
  final VoidCallback onTap;

  const _GenderButton({
    required this.label,
    required this.icon,
    required this.value,
    required this.selectedGender,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = selectedGender == value;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.08)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadius.sm),
          border: Border.all(
            color: isSelected ? AppColors.primary : context.borderColor,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected
                  ? AppColors.primary
                  : context.mutedForegroundColor,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: isSelected
                    ? AppColors.primary
                    : context.mutedForegroundColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Read-only field ──────────────────────────────────────────────────────────

class _ReadOnlyField extends StatelessWidget {
  final String value;

  const _ReadOnlyField({required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: context.mutedColor,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: Border.all(color: context.borderColor),
      ),
      child: Text(
        value,
        style: TextStyle(
          fontSize: 14,
          color: context.mutedForegroundColor,
        ),
      ),
    );
  }
}
