import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:talk_flutter/core/constants/app_constants.dart';
import 'package:talk_flutter/core/enums/app_enums.dart';
import 'package:talk_flutter/core/extensions/extensions.dart';
import 'package:talk_flutter/presentation/blocs/auth/auth_bloc.dart';

/// Registration screen with phone verification
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
  String _selectedGender = 'unspecified';
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
    if (_codeController.text.trim().length == AppConstants.verificationCodeLength) {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('회원가입'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state.status == AuthStatus.authenticated) {
            context.go('/');
          } else if (state.status == AuthStatus.error && state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage!),
                backgroundColor: Theme.of(context).colorScheme.error,
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
          return SafeArea(
            child: Stepper(
              currentStep: _currentStep,
              onStepContinue: () {
                if (_currentStep == 0) {
                  _requestCode();
                } else if (_currentStep == 1) {
                  _verifyCode();
                } else if (_currentStep == 2) {
                  _register();
                }
              },
              onStepCancel: () {
                if (_currentStep > 0) {
                  setState(() => _currentStep--);
                } else {
                  context.pop();
                }
              },
              controlsBuilder: (context, details) {
                return Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: FilledButton(
                          onPressed: state.isLoading ? null : details.onStepContinue,
                          child: state.isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : Text(_getButtonText()),
                        ),
                      ),
                      if (_currentStep > 0) ...[
                        const SizedBox(width: 12),
                        OutlinedButton(
                          onPressed: details.onStepCancel,
                          child: const Text('이전'),
                        ),
                      ],
                    ],
                  ),
                );
              },
              steps: [
                // Step 1: Phone Number
                Step(
                  title: const Text('전화번호 입력'),
                  subtitle: const Text('인증코드를 받을 전화번호를 입력하세요'),
                  isActive: _currentStep >= 0,
                  state: _currentStep > 0 ? StepState.complete : StepState.indexed,
                  content: _buildPhoneStep(),
                ),
                // Step 2: Verification Code
                Step(
                  title: const Text('인증코드 확인'),
                  subtitle: const Text('SMS로 받은 6자리 코드를 입력하세요'),
                  isActive: _currentStep >= 1,
                  state: _currentStep > 1 ? StepState.complete : StepState.indexed,
                  content: _buildCodeStep(),
                ),
                // Step 3: Profile Setup
                Step(
                  title: const Text('프로필 설정'),
                  subtitle: const Text('닉네임과 비밀번호를 설정하세요'),
                  isActive: _currentStep >= 2,
                  state: StepState.indexed,
                  content: _buildProfileStep(),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  String _getButtonText() {
    switch (_currentStep) {
      case 0:
        return '인증코드 요청';
      case 1:
        return '코드 확인';
      case 2:
        return '회원가입 완료';
      default:
        return '다음';
    }
  }

  Widget _buildPhoneStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: _phoneController,
          keyboardType: TextInputType.phone,
          maxLength: 11,
          decoration: const InputDecoration(
            labelText: '전화번호',
            hintText: '01012345678',
            prefixIcon: Icon(Icons.phone),
            border: OutlineInputBorder(),
            counterText: '',
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
        const SizedBox(height: 8),
        Text(
          '"-" 없이 숫자만 입력하세요',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
        const SizedBox(height: 16),
        // Dev skip button
        _buildDevSkipSection(),
      ],
    );
  }

  Widget _buildCodeStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: _codeController,
          keyboardType: TextInputType.number,
          maxLength: 6,
          decoration: const InputDecoration(
            labelText: '인증코드',
            hintText: '123456',
            prefixIcon: Icon(Icons.lock_outline),
            border: OutlineInputBorder(),
            counterText: '',
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
        const SizedBox(height: 8),
        Row(
          children: [
            Text(
              '코드를 받지 못하셨나요?',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            TextButton(
              onPressed: _requestCode,
              child: const Text('재발송'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(
                Icons.info_outline,
                size: 16,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '테스트: 코드 111111을 사용하세요',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        // Dev skip button
        _buildDevSkipSection(),
      ],
    );
  }

  Widget _buildProfileStep() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Nickname
          TextFormField(
            controller: _nicknameController,
            maxLength: AppConstants.maxNicknameLength,
            decoration: const InputDecoration(
              labelText: '닉네임',
              hintText: '사용할 닉네임을 입력하세요',
              prefixIcon: Icon(Icons.person),
              border: OutlineInputBorder(),
            ),
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
          const SizedBox(height: 16),

          // Gender
          DropdownButtonFormField<String>(
            initialValue: _selectedGender,
            decoration: const InputDecoration(
              labelText: '성별',
              prefixIcon: Icon(Icons.wc),
              border: OutlineInputBorder(),
            ),
            items: const [
              DropdownMenuItem(value: 'unspecified', child: Text('선택 안함')),
              DropdownMenuItem(value: 'male', child: Text('남성')),
              DropdownMenuItem(value: 'female', child: Text('여성')),
            ],
            onChanged: (value) {
              if (value != null) {
                setState(() => _selectedGender = value);
              }
            },
          ),
          const SizedBox(height: 16),

          // Password
          TextFormField(
            controller: _passwordController,
            obscureText: _obscurePassword,
            decoration: InputDecoration(
              labelText: '비밀번호',
              prefixIcon: const Icon(Icons.lock),
              border: const OutlineInputBorder(),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility_off : Icons.visibility,
                ),
                onPressed: () {
                  setState(() => _obscurePassword = !_obscurePassword);
                },
              ),
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
          const SizedBox(height: 16),

          // Confirm Password
          TextFormField(
            controller: _confirmPasswordController,
            obscureText: _obscureConfirmPassword,
            decoration: InputDecoration(
              labelText: '비밀번호 확인',
              prefixIcon: const Icon(Icons.lock_outline),
              border: const OutlineInputBorder(),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureConfirmPassword
                      ? Icons.visibility_off
                      : Icons.visibility,
                ),
                onPressed: () {
                  setState(() => _obscureConfirmPassword = !_obscureConfirmPassword);
                },
              ),
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
        ],
      ),
    );
  }

  /// Dev section with skip and quick login buttons
  Widget _buildDevSkipSection() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.developer_mode,
                size: 16,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 4),
              Text(
                '개발용 옵션',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Skip verification button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                // Skip to profile step
                setState(() => _currentStep = 2);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('[개발용] 인증을 건너뜁니다.')),
                );
              },
              icon: const Icon(Icons.skip_next),
              label: const Text('인증 패스하기'),
            ),
          ),
          const SizedBox(height: 8),
          const Divider(),
          const SizedBox(height: 8),
          Text(
            '기존 테스트 계정으로 바로 로그인',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 8),
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
                  child: const Text('김채현'),
                ),
              ),
              const SizedBox(width: 8),
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
                  child: const Text('이지원'),
                ),
              ),
              const SizedBox(width: 8),
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
