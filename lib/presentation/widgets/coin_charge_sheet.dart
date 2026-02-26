import 'package:flutter/material.dart';
import 'package:talk_flutter/core/theme/theme.dart';

// ─────────────────────────────────────────────────────────────
// 코인 충전 패키지 데이터
// ─────────────────────────────────────────────────────────────

class CoinPackageData {
  final String label;
  final int coins;
  final int price;
  final String? savings;
  final bool isRecommended;

  const CoinPackageData({
    required this.label,
    required this.coins,
    required this.price,
    this.savings,
    this.isRecommended = false,
  });

  String get priceText {
    final formatted = price.toString().replaceAllMapped(
          RegExp(r'(\d)(?=(\d{3})+$)'),
          (m) => '${m[1]},',
        );
    return '₩$formatted';
  }

  static const List<CoinPackageData> packages = [
    CoinPackageData(
      label: '기본',
      coins: 50,
      price: 4900,
    ),
    CoinPackageData(
      label: '인기',
      coins: 120,
      price: 9900,
      savings: '16% 절약',
      isRecommended: true,
    ),
    CoinPackageData(
      label: '프리미엄',
      coins: 280,
      price: 19900,
      savings: '28% 절약',
    ),
  ];
}

// ─────────────────────────────────────────────────────────────
// 코인 충전 바텀시트 진입점
// ─────────────────────────────────────────────────────────────

void showCoinChargeSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: context.cardColor,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(AppRadius.xl),
      ),
    ),
    builder: (_) => const CoinChargeSheet(),
  );
}

// ─────────────────────────────────────────────────────────────
// 바텀시트 본체
// ─────────────────────────────────────────────────────────────

class CoinChargeSheet extends StatelessWidget {
  const CoinChargeSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.md,
          AppSpacing.lg,
          AppSpacing.lg,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 핸들
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: context.borderColor,
                borderRadius: BorderRadius.circular(AppRadius.full),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // 헤더
            Row(
              children: [
                Text(
                  '코인 충전',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: context.textPrimary,
                      ),
                ),
                const SizedBox(width: AppSpacing.xs),
                const Icon(
                  Icons.bolt_rounded,
                  color: AppColors.primary,
                  size: AppIconSize.md,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xxs),
            Text(
              '더 많이 충전할수록 코인당 가격이 낮아져요',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: context.mutedForegroundColor,
                  ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // 3개 패키지 카드
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (int i = 0;
                      i < CoinPackageData.packages.length;
                      i++) ...[
                    if (i > 0) const SizedBox(width: AppSpacing.xs),
                    Expanded(
                      child: CoinPackageCard(
                        package: CoinPackageData.packages[i],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            // 안내 텍스트
            Text(
              '코인 결제 기능은 곧 오픈 예정이에요 🎉',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: context.mutedForegroundColor,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// 개별 패키지 카드
// ─────────────────────────────────────────────────────────────

class CoinPackageCard extends StatelessWidget {
  final CoinPackageData package;

  const CoinPackageCard({super.key, required this.package});

  @override
  Widget build(BuildContext context) {
    final pkg = package;
    return Container(
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: pkg.isRecommended ? AppColors.primary : context.borderColor,
          width: pkg.isRecommended ? 2 : 1,
        ),
        boxShadow: pkg.isRecommended
            ? [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.18),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ]
            : [
                BoxShadow(
                  color: context.shadowColor,
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          // 헤더 배너
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
            color: pkg.isRecommended ? AppColors.primary : context.mutedColor,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Text(
                  pkg.label,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: pkg.isRecommended
                        ? Colors.white
                        : context.mutedForegroundColor,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
                if (pkg.isRecommended)
                  const Positioned(
                    right: AppSpacing.xs,
                    child: Text('🔥', style: TextStyle(fontSize: 11)),
                  ),
              ],
            ),
          ),

          // 본문
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.xs,
                vertical: AppSpacing.md,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // 코인 아이콘 + 수량
                  Column(
                    children: [
                      Icon(
                        Icons.monetization_on_rounded,
                        size: pkg.isRecommended
                            ? AppIconSize.xxl
                            : AppIconSize.xl,
                        color: AppColors.primary,
                      ),
                      const SizedBox(height: AppSpacing.xxs),
                      Text(
                        '${pkg.coins}코인',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: pkg.isRecommended ? 16 : 14,
                          fontWeight: FontWeight.w800,
                          color: context.textPrimary,
                        ),
                      ),
                    ],
                  ),

                  // 가격 + 절약 배지
                  Column(
                    children: [
                      Text(
                        pkg.priceText,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: pkg.isRecommended ? 15 : 13,
                          fontWeight: FontWeight.w700,
                          color: context.textPrimary,
                        ),
                      ),
                      if (pkg.savings != null) ...[
                        const SizedBox(height: AppSpacing.xxs),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            borderRadius:
                                BorderRadius.circular(AppRadius.full),
                          ),
                          child: Text(
                            pkg.savings!,
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ] else
                        const SizedBox(height: AppSpacing.md),
                    ],
                  ),

                  // 충전 버튼
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () {},
                      style: FilledButton.styleFrom(
                        backgroundColor: pkg.isRecommended
                            ? AppColors.primary
                            : context.mutedColor,
                        foregroundColor: pkg.isRecommended
                            ? Colors.white
                            : context.textPrimary,
                        padding:
                            const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(AppRadius.sm),
                        ),
                        minimumSize: const Size(0, 36),
                        elevation: 0,
                        textStyle: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      child: const Text('충전'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
