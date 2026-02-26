import 'package:flutter/material.dart';
import 'package:talk_flutter/core/theme/theme.dart';

/// Help screen with FAQ sections
class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

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
          '도움말',
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
      body: ListView(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md,
        ),
        children: [
          _ContentCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                _HelpSection(
                  title: '시작하기',
                  items: [
                    _HelpItem(
                      q: '보이스팅은 어떤 앱인가요?',
                      a: '보이스팅은 음성 기반 소셜 네트워킹 앱입니다. 음성 메시지를 브로드캐스트하거나 1:1 대화를 할 수 있습니다.',
                    ),
                    _HelpItem(
                      q: '어떻게 가입하나요?',
                      a: '전화번호로 SMS 인증 후 닉네임을 설정하면 바로 시작할 수 있습니다.',
                    ),
                  ],
                ),
                _HelpSection(
                  title: '브로드캐스트',
                  items: [
                    _HelpItem(
                      q: '브로드캐스트란 무엇인가요?',
                      a: '음성 메시지를 여러 사용자에게 동시에 전송하는 기능입니다.',
                    ),
                    _HelpItem(
                      q: '브로드캐스트는 얼마나 보관되나요?',
                      a: '브로드캐스트는 6일 후 자동으로 만료됩니다.',
                    ),
                    _HelpItem(
                      q: '브로드캐스트에 답장할 수 있나요?',
                      a: '네, 받은 브로드캐스트에 음성 메시지로 답장하면 1:1 대화가 시작됩니다.',
                    ),
                  ],
                ),
                _HelpSection(
                  title: '대화',
                  items: [
                    _HelpItem(
                      q: '1:1 대화는 어떻게 시작하나요?',
                      a: '브로드캐스트에 답장하면 자동으로 1:1 대화가 시작됩니다.',
                    ),
                    _HelpItem(
                      q: '대화를 삭제하면 상대방도 삭제되나요?',
                      a: '아니요, 대화 삭제는 본인의 대화 목록에서만 삭제됩니다.',
                    ),
                  ],
                ),
                _HelpSection(
                  title: '안전',
                  isLast: true,
                  items: [
                    _HelpItem(
                      q: '다른 사용자를 차단하려면?',
                      a: '대화 화면이나 브로드캐스트 상세에서 메뉴 > 차단하기를 선택하세요.',
                    ),
                    _HelpItem(
                      q: '신고는 어떻게 하나요?',
                      a: '메뉴 > 신고하기를 선택하여 사유를 입력하면 됩니다.',
                      isLast: true,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),
        ],
      ),
    );
  }
}

class _ContentCard extends StatelessWidget {
  final Widget child;

  const _ContentCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
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
      child: child,
    );
  }
}

class _HelpSection extends StatelessWidget {
  final String title;
  final List<_HelpItem> items;
  final bool isLast;

  const _HelpSection({
    required this.title,
    required this.items,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            AppSpacing.md,
            AppSpacing.md,
            AppSpacing.xs,
          ),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
              letterSpacing: 0.2,
            ),
          ),
        ),
        ...items,
        if (!isLast)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Divider(
              height: 1,
              color: context.borderColor,
            ),
          ),
      ],
    );
  }
}

class _HelpItem extends StatelessWidget {
  final String q;
  final String a;
  final bool isLast;

  const _HelpItem({
    required this.q,
    required this.a,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        dividerColor: Colors.transparent,
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: 2,
        ),
        childrenPadding: const EdgeInsets.fromLTRB(
          AppSpacing.md,
          0,
          AppSpacing.md,
          AppSpacing.md,
        ),
        iconColor: AppColors.primary,
        collapsedIconColor: context.mutedForegroundColor,
        title: Text(
          q,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: context.textPrimary,
          ),
        ),
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: context.mutedColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              a,
              style: TextStyle(
                fontSize: 13,
                color: context.textSecondary,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
