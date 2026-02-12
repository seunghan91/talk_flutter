import 'package:flutter/material.dart';
import 'package:talk_flutter/core/theme/theme.dart';

/// Privacy policy screen
class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('개인정보처리방침')),
      body: SingleChildScrollView(
        padding: AppSpacing.screenPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Talkk 개인정보처리방침',
              style: textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            AppSpacing.verticalXs,
            Text(
              '최종 업데이트: 2025년 2월 1일',
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            AppSpacing.verticalXl,

            _SectionTitle(title: '1. 수집하는 개인정보'),
            _SectionBody(
              text: 'Talkk는 서비스 제공을 위해 다음과 같은 개인정보를 수집합니다.\n\n'
                  '- 필수 정보: 전화번호, 닉네임\n'
                  '- 선택 정보: 성별, 프로필 사진\n'
                  '- 자동 수집 정보: 기기 정보, 앱 사용 기록, 접속 로그',
            ),
            AppSpacing.verticalMd,

            _SectionTitle(title: '2. 개인정보의 수집 및 이용 목적'),
            _SectionBody(
              text: '수집된 개인정보는 다음 목적으로 이용됩니다.\n\n'
                  '- 회원 가입 및 관리\n'
                  '- 음성 메시지 서비스 제공\n'
                  '- 사용자 간 커뮤니케이션 지원\n'
                  '- 서비스 개선 및 새로운 서비스 개발\n'
                  '- 불법 및 부적절한 서비스 이용 방지',
            ),
            AppSpacing.verticalMd,

            _SectionTitle(title: '3. 개인정보의 보유 및 이용 기간'),
            _SectionBody(
              text: '회원 탈퇴 시 개인정보는 즉시 파기됩니다. 단, 관련 법령에 따라 보존이 필요한 경우 해당 기간 동안 보관합니다.\n\n'
                  '- 계약 또는 청약 철회에 관한 기록: 5년\n'
                  '- 소비자 불만 또는 분쟁 처리에 관한 기록: 3년\n'
                  '- 접속에 관한 기록: 3개월',
            ),
            AppSpacing.verticalMd,

            _SectionTitle(title: '4. 개인정보의 제3자 제공'),
            _SectionBody(
              text: 'Talkk는 원칙적으로 사용자의 개인정보를 제3자에게 제공하지 않습니다. '
                  '다만, 사용자의 동의가 있거나 법령에 의해 요구되는 경우에 한하여 제공할 수 있습니다.',
            ),
            AppSpacing.verticalMd,

            _SectionTitle(title: '5. 개인정보의 파기 절차 및 방법'),
            _SectionBody(
              text: '개인정보는 수집 및 이용 목적이 달성된 후 즉시 파기됩니다.\n\n'
                  '- 전자적 파일 형태: 복구 불가능한 방법으로 삭제\n'
                  '- 종이 문서: 분쇄기로 분쇄하거나 소각',
            ),
            AppSpacing.verticalMd,

            _SectionTitle(title: '6. 이용자의 권리'),
            _SectionBody(
              text: '사용자는 언제든지 다음 권리를 행사할 수 있습니다.\n\n'
                  '- 개인정보 열람 요구\n'
                  '- 오류 정정 요구\n'
                  '- 삭제 요구\n'
                  '- 처리 정지 요구',
            ),
            AppSpacing.verticalMd,

            _SectionTitle(title: '7. 연락처'),
            _SectionBody(
              text: '개인정보 관련 문의 사항이 있으시면 아래로 연락해 주세요.\n\n'
                  '이메일: privacy@talkk.app',
            ),

            AppSpacing.verticalXxl,
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
    );
  }
}

class _SectionBody extends StatelessWidget {
  final String text;

  const _SectionBody({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.xs),
      child: Text(
        text,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              height: 1.6,
            ),
      ),
    );
  }
}
