import 'package:flutter/material.dart';
import 'package:talk_flutter/core/theme/theme.dart';

/// Terms of service screen
class TermsOfServiceScreen extends StatelessWidget {
  const TermsOfServiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.mutedColor,
      appBar: AppBar(
        backgroundColor: context.surfaceColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          color: context.textPrimary,
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Text(
          '이용약관',
          style: TextStyle(
            color: context.textPrimary,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        centerTitle: false,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            color: context.borderColor,
            height: 1,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: context.cardColor,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: context.borderColor, width: 1),
                boxShadow: [
                  BoxShadow(
                    color: context.shadowColor,
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '보이스팅 서비스 이용약관',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: context.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '최종 업데이트: 2025년 2월 1일',
                    style: TextStyle(
                      fontSize: 12,
                      color: context.mutedForegroundColor,
                    ),
                  ),

                  const SizedBox(height: AppSpacing.lg),
                  Divider(color: context.borderColor, height: 1),
                  const SizedBox(height: AppSpacing.lg),

                  const _SectionTitle(title: '제1조 (목적)'),
                  const _SectionBody(
                    text: '이 약관은 보이스팅(이하 "회사")가 제공하는 음성 기반 소셜 네트워킹 서비스(이하 "서비스")의 '
                        '이용 조건 및 절차, 회사와 회원 간의 권리, 의무 및 책임 사항 등을 규정함을 목적으로 합니다.',
                  ),
                  const SizedBox(height: AppSpacing.md),

                  const _SectionTitle(title: '제2조 (정의)'),
                  const _SectionBody(
                    text: '1. "서비스"란 회사가 제공하는 음성 메시지 브로드캐스트 및 1:1 대화 서비스를 말합니다.\n'
                        '2. "회원"이란 이 약관에 동의하고 서비스를 이용하는 자를 말합니다.\n'
                        '3. "브로드캐스트"란 음성 메시지를 다수의 사용자에게 전송하는 기능을 말합니다.\n'
                        '4. "콘텐츠"란 회원이 서비스 내에서 생성하는 음성 메시지, 텍스트 등을 말합니다.',
                  ),
                  const SizedBox(height: AppSpacing.md),

                  const _SectionTitle(title: '제3조 (회원가입)'),
                  const _SectionBody(
                    text: '1. 서비스 이용을 희망하는 자는 전화번호 인증을 통해 회원가입을 할 수 있습니다.\n'
                        '2. 회사는 다음 각 호에 해당하는 경우 가입을 거절할 수 있습니다.\n'
                        '  - 타인의 정보를 도용한 경우\n'
                        '  - 필수 정보를 허위로 기재한 경우\n'
                        '  - 기타 서비스 운영에 지장을 초래하는 경우',
                  ),
                  const SizedBox(height: AppSpacing.md),

                  const _SectionTitle(title: '제4조 (서비스 이용)'),
                  const _SectionBody(
                    text: '1. 서비스는 회사의 영업 방침에 따라 정해진 시간 동안 제공됩니다.\n'
                        '2. 브로드캐스트는 전송 후 6일이 경과하면 자동으로 만료됩니다.\n'
                        '3. 회사는 서비스 개선을 위해 사전 공지 후 서비스를 변경할 수 있습니다.',
                  ),
                  const SizedBox(height: AppSpacing.md),

                  const _SectionTitle(title: '제5조 (회원의 의무)'),
                  const _SectionBody(
                    text: '회원은 다음 행위를 하여서는 안 됩니다.\n\n'
                        '- 타인의 개인정보를 수집, 저장, 공개하는 행위\n'
                        '- 음란, 폭력적이거나 혐오스러운 콘텐츠를 전송하는 행위\n'
                        '- 다른 회원에게 불쾌감을 주는 행위\n'
                        '- 서비스의 정상적인 운영을 방해하는 행위\n'
                        '- 상업적 목적으로 서비스를 이용하는 행위',
                  ),
                  const SizedBox(height: AppSpacing.md),

                  const _SectionTitle(title: '제6조 (서비스 제한 및 중지)'),
                  const _SectionBody(
                    text: '회사는 다음 경우에 서비스 이용을 제한하거나 중지할 수 있습니다.\n\n'
                        '- 회원이 제5조의 의무를 위반한 경우\n'
                        '- 서비스 설비의 보수 등 공사로 인한 부득이한 경우\n'
                        '- 천재지변, 국가 비상사태 등 불가항력적인 사유가 있는 경우',
                  ),
                  const SizedBox(height: AppSpacing.md),

                  const _SectionTitle(title: '제7조 (탈퇴 및 자격 상실)'),
                  const _SectionBody(
                    text: '1. 회원은 언제든지 서비스 내 설정을 통해 탈퇴를 요청할 수 있습니다.\n'
                        '2. 탈퇴 시 회원의 개인정보와 콘텐츠는 관련 법령에서 정한 경우를 제외하고 즉시 삭제됩니다.',
                  ),
                  const SizedBox(height: AppSpacing.md),

                  const _SectionTitle(title: '제8조 (면책 조항)'),
                  const _SectionBody(
                    text: '1. 회사는 회원 간 전송되는 콘텐츠의 내용에 대해 책임을 지지 않습니다.\n'
                        '2. 회사는 천재지변 또는 이에 준하는 불가항력으로 인해 서비스를 제공할 수 없는 경우에는 '
                        '서비스 제공에 관한 책임이 면제됩니다.',
                  ),
                  const SizedBox(height: AppSpacing.md),

                  const _SectionTitle(title: '제9조 (분쟁 해결)'),
                  const _SectionBody(
                    text: '서비스 이용으로 발생한 분쟁에 대해 회사와 회원은 성실히 협의하여 해결하도록 합니다. '
                        '협의가 이루어지지 않는 경우 관련 법령에 따른 관할 법원에 소를 제기할 수 있습니다.',
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),
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
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: context.textPrimary,
        ),
      ),
    );
  }
}

class _SectionBody extends StatelessWidget {
  final String text;

  const _SectionBody({required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 13,
        color: context.textSecondary,
        height: 1.6,
      ),
    );
  }
}
