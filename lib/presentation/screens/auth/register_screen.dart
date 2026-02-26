import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:talk_flutter/core/constants/app_constants.dart';
import 'package:talk_flutter/core/enums/app_enums.dart';
import 'package:talk_flutter/core/extensions/extensions.dart';
import 'package:talk_flutter/core/theme/theme.dart';
import 'package:talk_flutter/core/utils/nickname_generator.dart';
import 'package:talk_flutter/presentation/blocs/auth/auth_bloc.dart';

/// Registration screen with phone verification - 보이스팅 design system
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _codeController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _nicknameController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  String _selectedGender = 'unknown';
  int _currentStep = 0;

  @override
  void dispose() {
    _phoneController.dispose();
    _codeController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nicknameController.dispose();
    super.dispose();
  }

  void _requestCode() {
    if (_phoneController.text.trim().length >= 10) {
      context.read<AuthBloc>().add(
            AuthRequestCodeRequested(
              phoneNumber: _phoneController.text.trim(),
            ),
          );
    }
  }

  void _verifyCode() {
    if (_codeController.text.trim().length ==
        AppConstants.verificationCodeLength) {
      context.read<AuthBloc>().add(
            AuthVerifyCodeRequested(
              phoneNumber: _phoneController.text.trim(),
              code: _codeController.text.trim(),
            ),
          );
    }
  }

  void _register() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<AuthBloc>().add(
            AuthRegisterRequested(
              phoneNumber: _phoneController.text.trim(),
              password: _passwordController.text,
              nickname: _nicknameController.text.trim(),
              gender: _selectedGender,
            ),
          );
    }
  }

  String get _stepSubtitle {
    switch (_currentStep) {
      case 0:
        return '인증코드를 받을 전화번호를 입력하세요';
      case 1:
        return 'SMS로 받은 6자리 코드를 입력하세요';
      case 2:
        return '닉네임과 비밀번호를 설정하세요';
      default:
        return '';
    }
  }

  String get _buttonText {
    switch (_currentStep) {
      case 0:
        return '인증 코드 받기';
      case 1:
        return '코드 확인';
      case 2:
        return '회원가입';
      default:
        return '다음';
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: AppColors.primary, size: 20),
          onPressed: () {
            if (_currentStep > 0) {
              setState(() => _currentStep--);
            } else {
              context.pop();
            }
          },
        ),
      ),
      extendBodyBehindAppBar: true,
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state.status == AuthStatus.authenticated) {
            context.go('/');
          } else if (state.status == AuthStatus.error &&
              state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage!),
                backgroundColor: colorScheme.error,
              ),
            );
          } else if (state.isCodeSent && _currentStep == 0) {
            setState(() => _currentStep = 1);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('인증코드가 발송되었습니다.')),
            );
          } else if (state.isCodeVerified && _currentStep == 1) {
            setState(() => _currentStep = 2);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('인증이 완료되었습니다.')),
            );
          }
        },
        builder: (context, state) {
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: const [0.0, 1.0],
                colors: [
                  context.surfaceColor,
                  const Color(0x4DFFD4D8), // #FFD4D8 at ~30% opacity
                ],
              ),
            ),
            child: SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xl,
                    vertical: AppSpacing.md,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Logo
                      Container(
                        width: 80,
                        height: 80,
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.favorite_rounded,
                          color: Colors.white,
                          size: 40,
                        ),
                      ),
                      AppSpacing.verticalMd,

                      // Title
                      Text(
                        _currentStep == 2 ? '프로필 설정' : '보이스팅',
                        textAlign: TextAlign.center,
                        style: Theme.of(context)
                            .textTheme
                            .headlineLarge
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                      ),
                      AppSpacing.verticalXs,

                      // Subtitle
                      Text(
                        _stepSubtitle,
                        textAlign: TextAlign.center,
                        style:
                            Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: context.mutedForegroundColor,
                                ),
                      ),
                      const SizedBox(height: AppSpacing.xxl),

                      // Step card
                      Container(
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
                        padding: const EdgeInsets.all(AppSpacing.xl),
                        child: _currentStep == 0
                            ? _buildPhoneStep(state)
                            : _currentStep == 1
                                ? _buildCodeStep(state)
                                : _buildProfileStep(state),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPhoneStep(AuthState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _StyledTextField(
          controller: _phoneController,
          hintText: '전화번호 (01012345678)',
          keyboardType: TextInputType.phone,
          maxLength: 11,
          validator: (value) {
            if (value.isNullOrBlank) {
              return '전화번호를 입력해주세요';
            }
            if (!value!.isValidPhoneNumber) {
              return '올바른 전화번호 형식이 아닙니다';
            }
            return null;
          },
        ),
        AppSpacing.verticalXs,
        Text(
          '"-" 없이 숫자만 입력하세요',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: context.mutedForegroundColor,
              ),
        ),
        AppSpacing.verticalXl,

        // Primary button
        _PrimaryButton(
          label: _buttonText,
          isLoading: state.isLoading,
          onPressed: _requestCode,
        ),

        AppSpacing.verticalLg,
        _buildDevSkipSection(),
      ],
    );
  }

  Widget _buildCodeStep(AuthState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Large centered code input
        _StyledTextField(
          controller: _codeController,
          hintText: '인증코드 6자리',
          keyboardType: TextInputType.number,
          maxLength: 6,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            letterSpacing: 8,
            color: context.textPrimary,
          ),
          validator: (value) {
            if (value.isNullOrBlank) {
              return '인증코드를 입력해주세요';
            }
            if (value!.length != 6) {
              return '6자리 인증코드를 입력해주세요';
            }
            return null;
          },
        ),
        AppSpacing.verticalXs,

        // Resend row
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '코드를 받지 못하셨나요?',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: context.mutedForegroundColor,
                  ),
            ),
            TextButton(
              onPressed: _requestCode,
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xs, vertical: 0),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Text(
                '재발송',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),

        AppSpacing.verticalXs,
        Container(
          padding: const EdgeInsets.all(AppSpacing.sm),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(AppRadius.sm),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.info_outline,
                size: AppIconSize.sm,
                color: AppColors.primary,
              ),
              AppSpacing.horizontalXs,
              Expanded(
                child: Text(
                  '테스트: 코드 111111을 사용하세요',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.primary,
                      ),
                ),
              ),
            ],
          ),
        ),

        AppSpacing.verticalXl,

        _PrimaryButton(
          label: _buttonText,
          isLoading: state.isLoading,
          onPressed: _verifyCode,
        ),

        AppSpacing.verticalLg,
        _buildDevSkipSection(),
      ],
    );
  }

  Widget _buildProfileStep(AuthState state) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Nickname
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _StyledTextField(
                  controller: _nicknameController,
                  hintText: '닉네임 (예: 행복한고양이)',
                  maxLength: AppConstants.maxNicknameLength,
                  validator: (value) {
                    if (value.isNullOrBlank) {
                      return '닉네임을 입력해주세요';
                    }
                    if (value!.length < 2) {
                      return '닉네임은 2자 이상이어야 합니다';
                    }
                    return null;
                  },
                ),
              ),
              AppSpacing.horizontalSm,
              SizedBox(
                height: 48,
                child: OutlinedButton(
                  onPressed: () {
                    setState(() {
                      _nicknameController.text = NicknameGenerator.generate();
                    });
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.primary),
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                  ),
                  child: const Icon(Icons.refresh_rounded, size: 20),
                ),
              ),
            ],
          ),
          AppSpacing.verticalXxs,
          Text(
            '버튼을 눌러 자동 생성하거나 직접 입력하세요',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: context.mutedForegroundColor,
                ),
          ),
          AppSpacing.verticalMd,

          // Password
          _StyledTextField(
            controller: _passwordController,
            hintText: '비밀번호',
            obscureText: _obscurePassword,
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                color: context.mutedForegroundColor,
                size: 20,
              ),
              onPressed: () {
                setState(() => _obscurePassword = !_obscurePassword);
              },
            ),
            validator: (value) {
              if (value.isNullOrBlank) {
                return '비밀번호를 입력해주세요';
              }
              if (value!.length < AppConstants.minPasswordLength) {
                return '비밀번호는 ${AppConstants.minPasswordLength}자 이상이어야 합니다';
              }
              return null;
            },
          ),
          AppSpacing.verticalMd,

          // Confirm Password
          _StyledTextField(
            controller: _confirmPasswordController,
            hintText: '비밀번호 확인',
            obscureText: _obscureConfirmPassword,
            suffixIcon: IconButton(
              icon: Icon(
                _obscureConfirmPassword
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                color: context.mutedForegroundColor,
                size: 20,
              ),
              onPressed: () {
                setState(
                    () => _obscureConfirmPassword = !_obscureConfirmPassword);
              },
            ),
            validator: (value) {
              if (value.isNullOrBlank) {
                return '비밀번호 확인을 입력해주세요';
              }
              if (value != _passwordController.text) {
                return '비밀번호가 일치하지 않습니다';
              }
              return null;
            },
          ),
          AppSpacing.verticalMd,

          // Gender selector
          _GenderSelector(
            selected: _selectedGender,
            onChanged: (value) => setState(() => _selectedGender = value),
          ),
          AppSpacing.verticalXl,

          _PrimaryButton(
            label: _buttonText,
            isLoading: state.isLoading,
            onPressed: _register,
          ),
        ],
      ),
    );
  }

  Widget _buildDevSkipSection() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: context.mutedColor,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: context.borderColor),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.developer_mode,
                size: AppIconSize.sm,
                color: AppColors.primary,
              ),
              AppSpacing.horizontalXxs,
              Text(
                '개발용 옵션',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
          AppSpacing.verticalSm,
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                final phone = _phoneController.text.trim();
                if (phone.length >= 10) {
                  // 전화번호가 입력됐으면 서버에도 bypass 인증 처리
                  context.read<AuthBloc>().add(
                        AuthDevBypassVerificationRequested(phoneNumber: phone),
                      );
                } else {
                  // 전화번호 없으면 UI만 스킵
                  setState(() => _currentStep = 2);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('[개발용] 인증을 건너뜁니다.')),
                  );
                }
              },
              icon: const Icon(Icons.skip_next),
              label: const Text('인증 패스하기'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: BorderSide(color: context.borderColor),
              ),
            ),
          ),
          AppSpacing.verticalXs,
          Divider(color: Theme.of(context).dividerColor),
          AppSpacing.verticalXs,
          Text(
            '기존 테스트 계정으로 바로 로그인',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: context.mutedForegroundColor,
                ),
          ),
          AppSpacing.verticalXs,
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    context.read<AuthBloc>().add(
                          const AuthLoginRequested(
                            phoneNumber: '01011111111',
                            password: 'password',
                          ),
                        );
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: BorderSide(color: context.borderColor),
                    padding: EdgeInsets.zero,
                  ),
                  child: const Text('김채현'),
                ),
              ),
              AppSpacing.horizontalXs,
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    context.read<AuthBloc>().add(
                          const AuthLoginRequested(
                            phoneNumber: '01022222222',
                            password: 'password',
                          ),
                        );
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: BorderSide(color: context.borderColor),
                    padding: EdgeInsets.zero,
                  ),
                  child: const Text('이지원'),
                ),
              ),
              AppSpacing.horizontalXs,
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    context.read<AuthBloc>().add(
                          const AuthLoginRequested(
                            phoneNumber: '01033333333',
                            password: 'password',
                          ),
                        );
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: BorderSide(color: context.borderColor),
                    padding: EdgeInsets.zero,
                  ),
                  child: const Text('박지민'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Shared sub-widgets
// ---------------------------------------------------------------------------

/// Styled input field matching 보이스팅 design system
class _StyledTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final TextInputType? keyboardType;
  final bool obscureText;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;
  final int? maxLength;
  final TextAlign textAlign;
  final TextStyle? style;

  const _StyledTextField({
    required this.controller,
    required this.hintText,
    this.keyboardType,
    this.obscureText = false,
    this.suffixIcon,
    this.validator,
    this.maxLength,
    this.textAlign = TextAlign.start,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      maxLength: maxLength,
      textAlign: textAlign,
      validator: validator,
      style: style ??
          TextStyle(
            color: context.textPrimary,
            fontSize: 15,
          ),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(
          color: context.mutedForegroundColor,
          fontSize: 15,
        ),
        filled: true,
        fillColor: context.inputBgColor,
        counterText: '',
        suffixIcon: suffixIcon,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
          borderSide:
              const BorderSide(color: AppColors.error, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
          borderSide:
              const BorderSide(color: AppColors.error, width: 1.5),
        ),
      ),
    );
  }
}

/// Primary action button
class _PrimaryButton extends StatelessWidget {
  final String label;
  final bool isLoading;
  final VoidCallback? onPressed;

  const _PrimaryButton({
    required this.label,
    required this.isLoading,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.sm),
          ),
          elevation: 0,
        ),
        child: isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Text(
                label,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }
}

/// Gender selector - 2 button grid matching ProfileSetupPage.tsx
class _GenderSelector extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onChanged;

  const _GenderSelector({
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '성별',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: context.mutedForegroundColor,
                fontWeight: FontWeight.w500,
              ),
        ),
        AppSpacing.verticalXs,
        Row(
          children: [
            Expanded(
              child: _GenderButton(
                label: '남성',
                value: 'male',
                selected: selected,
                onTap: onChanged,
              ),
            ),
            AppSpacing.horizontalSm,
            Expanded(
              child: _GenderButton(
                label: '여성',
                value: 'female',
                selected: selected,
                onTap: onChanged,
              ),
            ),
          ],
        ),
        AppSpacing.verticalXs,
        SizedBox(
          width: double.infinity,
          child: _GenderButton(
            label: '선택 안함',
            value: 'unknown',
            selected: selected,
            onTap: onChanged,
          ),
        ),
      ],
    );
  }
}

class _GenderButton extends StatelessWidget {
  final String label;
  final String value;
  final String selected;
  final ValueChanged<String> onTap;

  const _GenderButton({
    required this.label,
    required this.value,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = selected == value;

    return GestureDetector(
      onTap: () => onTap(value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        height: 44,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.1)
              : context.inputBgColor,
          borderRadius: BorderRadius.circular(AppRadius.sm),
          border: Border.all(
            color: isSelected ? AppColors.primary : context.borderColor,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? AppColors.primary : context.mutedForegroundColor,
            fontWeight:
                isSelected ? FontWeight.w600 : FontWeight.w400,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}
