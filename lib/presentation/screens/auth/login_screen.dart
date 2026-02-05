import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:talk_flutter/core/enums/app_enums.dart';
import 'package:talk_flutter/core/extensions/extensions.dart';
import 'package:talk_flutter/core/theme/theme.dart';
import 'package:talk_flutter/presentation/blocs/auth/auth_bloc.dart';

/// Login screen
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
          } else if (state.status == AuthStatus.error && state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage!),
                backgroundColor: colorScheme.error,
              ),
            );
          }
        },
        builder: (context, state) {
          return SafeArea(
            child: Padding(
              padding: EdgeInsets.all(AppSpacing.xl),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Spacer(),

                    // Logo & Title
                    Icon(
                      Icons.record_voice_over,
                      size: AppIconSize.heroLarge,
                      color: colorScheme.primary,
                    ),
                    AppSpacing.verticalMd,
                    Text(
                      'Talkk',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.primary,
                          ),
                    ),
                    AppSpacing.verticalXs,
                    Text(
                      '음성으로 연결되는 새로운 소셜',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                    ),

                    const Spacer(),

                    // Phone number field
                    TextFormField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        labelText: '전화번호',
                        hintText: '01012345678',
                        prefixIcon: Icon(Icons.phone),
                        border: OutlineInputBorder(),
                      ),
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
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        labelText: '비밀번호',
                        prefixIcon: const Icon(Icons.lock),
                        border: const OutlineInputBorder(),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
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
                    FilledButton(
                      onPressed: state.isLoading ? null : _login,
                      child: state.isLoading
                          ? SizedBox(
                              height: AppIconSize.md,
                              width: AppIconSize.md,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: colorScheme.onPrimary,
                              ),
                            )
                          : const Text('로그인'),
                    ),
                    AppSpacing.verticalMd,

                    // Register link
                    TextButton(
                      onPressed: () => context.push('/auth/register'),
                      child: const Text('계정이 없으신가요? 회원가입'),
                    ),

                    AppSpacing.verticalXxl,

                    // Dev quick login buttons
                    const Divider(),
                    AppSpacing.verticalXs,
                    Container(
                      padding: EdgeInsets.all(AppSpacing.sm),
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerHighest,
                        borderRadius: AppRadius.mediumRadius,
                        border: Border.all(
                          color: colorScheme.outline.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.developer_mode,
                                size: AppIconSize.sm,
                                color: colorScheme.primary,
                              ),
                              AppSpacing.horizontalXxs,
                              Text(
                                '개발용 빠른 로그인',
                                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                      color: colorScheme.primary,
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                            ],
                          ),
                          AppSpacing.verticalSm,
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: state.isLoading
                                      ? null
                                      : () {
                                          context.read<AuthBloc>().add(
                                                const AuthLoginRequested(
                                                  phoneNumber: '01011111111',
                                                  password: 'password',
                                                ),
                                              );
                                        },
                                  child: const Text('김채현으로 로그인'),
                                ),
                              ),
                              AppSpacing.horizontalXs,
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: state.isLoading
                                      ? null
                                      : () {
                                          context.read<AuthBloc>().add(
                                                const AuthLoginRequested(
                                                  phoneNumber: '01022222222',
                                                  password: 'password',
                                                ),
                                              );
                                        },
                                  child: const Text('이지원으로 로그인'),
                                ),
                              ),
                            ],
                          ),
                          AppSpacing.verticalXs,
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton(
                              onPressed: state.isLoading
                                  ? null
                                  : () {
                                      context.read<AuthBloc>().add(
                                            const AuthLoginRequested(
                                              phoneNumber: '01033333333',
                                              password: 'password',
                                            ),
                                          );
                                    },
                              child: const Text('박지민으로 로그인'),
                            ),
                          ),
                        ],
                      ),
                    ),

                    AppSpacing.verticalMd,
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
