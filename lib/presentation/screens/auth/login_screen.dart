import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:talk_flutter/core/enums/app_enums.dart';
import 'package:talk_flutter/core/extensions/extensions.dart';
import 'package:talk_flutter/core/theme/theme.dart';
import 'package:talk_flutter/presentation/blocs/auth/auth_bloc.dart';

/// Login screen - 보이스팅 design system
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _login() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<AuthBloc>().add(
            AuthLoginRequested(
              phoneNumber: _phoneController.text.trim(),
              password: _passwordController.text,
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
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
                    vertical: AppSpacing.xl,
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

                      // App name
                      Text(
                        '보이스팅',
                        textAlign: TextAlign.center,
                        style:
                            Theme.of(context).textTheme.headlineLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                ),
                      ),
                      AppSpacing.verticalXs,

                      // Subtitle
                      Text(
                        '음성으로 전하는 설렘',
                        textAlign: TextAlign.center,
                        style:
                            Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: context.mutedForegroundColor,
                                ),
                      ),
                      const SizedBox(height: AppSpacing.xxl),

                      // Card
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
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // Phone number field
                              _StyledTextField(
                                controller: _phoneController,
                                hintText: '전화번호 (01012345678)',
                                keyboardType: TextInputType.phone,
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
                              AppSpacing.verticalMd,

                              // Password field
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
                                    setState(() {
                                      _obscurePassword = !_obscurePassword;
                                    });
                                  },
                                ),
                                validator: (value) {
                                  if (value.isNullOrBlank) {
                                    return '비밀번호를 입력해주세요';
                                  }
                                  if (value!.length < 6) {
                                    return '비밀번호는 6자 이상이어야 합니다';
                                  }
                                  return null;
                                },
                              ),
                              AppSpacing.verticalXl,

                              // Login button
                              SizedBox(
                                height: 52,
                                child: ElevatedButton(
                                  onPressed: state.isLoading ? null : _login,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primary,
                                    foregroundColor: Colors.white,
                                    disabledBackgroundColor:
                                        AppColors.primary.withValues(alpha: 0.5),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(
                                          AppRadius.sm),
                                    ),
                                    elevation: 0,
                                  ),
                                  child: state.isLoading
                                      ? const SizedBox(
                                          height: 20,
                                          width: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Colors.white,
                                          ),
                                        )
                                      : const Text(
                                          '로그인',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      AppSpacing.verticalMd,

                      // Register link
                      GestureDetector(
                        onTap: () => context.push('/auth/register'),
                        child: RichText(
                          text: TextSpan(
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(color: context.mutedForegroundColor),
                            children: const [
                              TextSpan(text: '계정이 없으신가요? '),
                              TextSpan(
                                text: '회원가입',
                                style: TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      if (kDebugMode) ...[
                        AppSpacing.verticalXxl,
                        _DebugQuickLogin(isLoading: state.isLoading),
                      ],

                      AppSpacing.verticalMd,
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
}

/// Styled text field matching 보이스팅 design system
class _StyledTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final TextInputType? keyboardType;
  final bool obscureText;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;
  const _StyledTextField({
    required this.controller,
    required this.hintText,
    this.keyboardType,
    this.obscureText = false,
    this.suffixIcon,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      validator: validator,
      style: TextStyle(
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
          borderSide: const BorderSide(color: AppColors.error, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
          borderSide: const BorderSide(color: AppColors.error, width: 1.5),
        ),
      ),
    );
  }
}

/// Debug quick login section
class _DebugQuickLogin extends StatelessWidget {
  final bool isLoading;

  const _DebugQuickLogin({required this.isLoading});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
                child: Divider(
                    color: Theme.of(context).dividerColor, thickness: 1)),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
              child: Text(
                '테스트 계정 퀵 로그인',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: context.mutedForegroundColor,
                    ),
              ),
            ),
            Expanded(
                child: Divider(
                    color: Theme.of(context).dividerColor, thickness: 1)),
          ],
        ),
        AppSpacing.verticalMd,
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          alignment: WrapAlignment.center,
          children: [
            _QuickLoginButton(
              name: '김채현',
              phone: '01011111111',
              isLoading: isLoading,
            ),
            _QuickLoginButton(
              name: '이지원',
              phone: '01022222222',
              isLoading: isLoading,
            ),
            _QuickLoginButton(
              name: '박지민',
              phone: '01033333333',
              isLoading: isLoading,
            ),
          ],
        ),
      ],
    );
  }
}

/// Helper widget for quick login buttons
class _QuickLoginButton extends StatelessWidget {
  final String name;
  final String phone;
  final bool isLoading;

  const _QuickLoginButton({
    required this.name,
    required this.phone,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      avatar: CircleAvatar(
        radius: 12,
        backgroundColor: AppColors.primary,
        child: Text(
          name[0],
          style: const TextStyle(
            color: Colors.white,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      label: Text(name),
      onPressed: isLoading
          ? null
          : () {
              context.read<AuthBloc>().add(
                    AuthLoginRequested(
                      phoneNumber: phone,
                      password: 'password',
                    ),
                  );
            },
    );
  }
}
