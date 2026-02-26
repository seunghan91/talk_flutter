import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:talk_flutter/core/theme/theme.dart';
import 'package:talk_flutter/presentation/blocs/broadcast/broadcast_bloc.dart';

/// Market screen with message purchase - 보이스팅 디자인 시스템
class MarketScreen extends StatelessWidget {
  const MarketScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: BlocBuilder<BroadcastBloc, BroadcastState>(
          builder: (context, state) {
            final remaining = state.limits.dailyRemaining;

            return ListView(
              padding: AppSpacing.screenPadding,
              children: [
                // 커스텀 헤더
                Padding(
                  padding: const EdgeInsets.only(
                    bottom: AppSpacing.lg,
                    top: AppSpacing.xs,
                  ),
                  child: Text(
                    '마켓',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ),

                // 현재 보유 메시지 카드
                _CurrentBalanceCard(remaining: remaining),
                AppSpacing.verticalMd,

                // 메시지 추가 구매 카드
                const _PurchaseCard(),
                AppSpacing.verticalMd,

                // 안내 카드
                const _InfoCard(),
                AppSpacing.verticalXxl,
              ],
            );
          },
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Shared card decoration helper
// ─────────────────────────────────────────────────────────────

BoxDecoration _cardDecoration(BuildContext context) {
  return BoxDecoration(
    color: context.cardColor,
    borderRadius: BorderRadius.circular(AppRadius.xl), // 18px ≈ rounded-2xl
    border: Border.all(color: context.borderColor),
    boxShadow: [
      BoxShadow(
        color: context.shadowColor,
        blurRadius: 8,
        offset: const Offset(0, 2),
      ),
    ],
  );
}

// ─────────────────────────────────────────────────────────────
// 현재 보유 메시지 카드
// ─────────────────────────────────────────────────────────────

class _CurrentBalanceCard extends StatelessWidget {
  final int remaining;

  const _CurrentBalanceCard({required this.remaining});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: _cardDecoration(context),
      child: Row(
        children: [
          // 좌측: 라벨 + 개수
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '현재 보유 메시지',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: context.mutedForegroundColor,
                      ),
                ),
                AppSpacing.verticalXxs,
                Row(
                  children: [
                    const Icon(
                      Icons.mail_outline,
                      size: AppIconSize.xl,
                      color: AppColors.primary,
                    ),
                    AppSpacing.horizontalXs,
                    Text(
                      '$remaining개',
                      style:
                          Theme.of(context).textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.w500,
                              ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // 우측: 충전 안내
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '매일 자정',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: context.mutedForegroundColor,
                    ),
              ),
              AppSpacing.verticalXxs,
              Text(
                '30개 무료 충전',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w500,
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// 메시지 추가 구매 카드
// ─────────────────────────────────────────────────────────────

class _PurchaseCard extends StatelessWidget {
  const _PurchaseCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: _cardDecoration(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 헤더 row
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppRadius.full),
                ),
                child: const Icon(
                  Icons.shopping_bag_outlined,
                  color: AppColors.primary,
                  size: AppIconSize.xl,
                ),
              ),
              AppSpacing.horizontalSm,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '메시지 추가 구매',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    Text(
                      '더 많은 대화를 나누세요',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: context.mutedForegroundColor,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          AppSpacing.verticalMd,

          // 그라데이션 내부 박스
          Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primary.withValues(alpha: 0.1),
                  AppColors.secondary.withValues(alpha: 0.2),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(AppRadius.sm), // 10px
            ),
            child: Column(
              children: [
                // 수량 / 가격 row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '+20개',
                          style: Theme.of(context)
                              .textTheme
                              .headlineLarge
                              ?.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w500,
                              ),
                        ),
                        Text(
                          '보이스 메시지',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: context.mutedForegroundColor,
                                  ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '₩2,000',
                          style: Theme.of(context)
                              .textTheme
                              .headlineMedium
                              ?.copyWith(
                                fontWeight: FontWeight.w500,
                              ),
                        ),
                        Text(
                          '일회성 결제',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: context.mutedForegroundColor,
                                    fontSize: 11,
                                  ),
                        ),
                      ],
                    ),
                  ],
                ),
                AppSpacing.verticalMd,

                // 체크리스트
                const _FeatureItem(text: '즉시 사용 가능'),
                AppSpacing.verticalXs,
                const _FeatureItem(text: '무료 충전량과 별도로 누적'),
                AppSpacing.verticalXs,
                const _FeatureItem(text: '자정 리셋 시에도 유지'),
              ],
            ),
          ),
          AppSpacing.verticalMd,

          // 결제 버튼
          SizedBox(
            width: double.infinity,
            height: 52,
            child: FilledButton(
              onPressed: () {
                // TODO: 결제 처리 - WalletBloc 연동
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('결제 기능은 준비 중입니다.')),
                );
              },
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.sm), // 10px
                ),
              ),
              child: const Text(
                '₩2,000 결제하기',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          AppSpacing.verticalXs,

          // 안전 결제 안내 (centered)
          SizedBox(
            width: double.infinity,
            child: Text(
              '안전한 결제 시스템을 통해 처리됩니다',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: context.mutedForegroundColor,
                    fontSize: 11,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// 체크리스트 아이템
// ─────────────────────────────────────────────────────────────

class _FeatureItem extends StatelessWidget {
  final String text;

  const _FeatureItem({required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(
          Icons.check_circle,
          size: 16,
          color: AppColors.primary,
        ),
        AppSpacing.horizontalXs,
        Expanded(
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────
// 안내 카드
// ─────────────────────────────────────────────────────────────

class _InfoCard extends StatelessWidget {
  const _InfoCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: context.accentColor.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(AppRadius.sm), // 10px
        border: Border.all(color: context.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '💡 메시지 충전 안내',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          AppSpacing.verticalXs,
          ...[
            '매일 자정(00시)에 무료로 30개가 자동 충전됩니다',
            '구매한 메시지는 무료 충전량과 별도로 누적됩니다',
            '사용하지 않은 메시지는 다음 날에도 유지됩니다',
          ].map(
            (text) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.xxs),
              child: Text(
                '• $text',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: context.mutedForegroundColor,
                    ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
