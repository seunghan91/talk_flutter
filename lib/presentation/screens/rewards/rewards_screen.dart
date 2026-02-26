import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:talk_flutter/core/theme/theme.dart';
import 'package:talk_flutter/presentation/blocs/wallet/wallet_bloc.dart';
import 'package:talk_flutter/presentation/blocs/wallet/wallet_state.dart';

/// Rewards Market screen — 코인 충전 + 적립 안내
class RewardsScreen extends StatelessWidget {
  const RewardsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: ListView(
          padding: AppSpacing.screenPadding,
          children: [
            // ── 헤더 ──────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.only(
                bottom: AppSpacing.lg,
                top: AppSpacing.xs,
              ),
              child: Row(
                children: [
                  Text(
                    '리워드 마켓',
                    style:
                        Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                  ),
                  AppSpacing.horizontalXs,
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.xs,
                      vertical: AppSpacing.xxs,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppRadius.full),
                    ),
                    child: Text(
                      'BETA',
                      style:
                          Theme.of(context).textTheme.labelSmall?.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w700,
                                fontSize: 10,
                              ),
                    ),
                  ),
                ],
              ),
            ),

            // ── 보유 코인 카드 ─────────────────────────────────
            const _CoinsBalanceCard(),
            AppSpacing.verticalLg,

            // ── 코인 충전 섹션 ─────────────────────────────────
            const _CoinChargeSection(),
            AppSpacing.verticalLg,

            // ── 코인 안내 카드 ─────────────────────────────────
            const _CoinInfoCard(),
            AppSpacing.verticalXxl,
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// 공통 카드 데코레이션
// ─────────────────────────────────────────────────────────────

BoxDecoration _cardDecoration(BuildContext context, {bool highlighted = false}) {
  return BoxDecoration(
    color: context.cardColor,
    borderRadius: BorderRadius.circular(AppRadius.xl),
    border: Border.all(
      color: highlighted ? AppColors.primary : context.borderColor,
      width: highlighted ? 2 : 1,
    ),
    boxShadow: highlighted
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
  );
}

// ─────────────────────────────────────────────────────────────
// 보유 코인 카드
// ─────────────────────────────────────────────────────────────

class _CoinsBalanceCard extends StatelessWidget {
  const _CoinsBalanceCard();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WalletBloc, WalletState>(
      builder: (context, walletState) {
        return Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: _cardDecoration(context),
          child: Row(
            children: [
              // 좌측: 보유 코인 + 개수
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '보유 코인',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: context.mutedForegroundColor,
                          ),
                    ),
                    AppSpacing.verticalXxs,
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.monetization_on_rounded,
                          size: AppIconSize.xl,
                          color: AppColors.primary,
                        ),
                        AppSpacing.horizontalXs,
                        Text(
                          '${walletState.balance}코인',
                          style: Theme.of(context)
                              .textTheme
                              .headlineMedium
                              ?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // 우측: 적립 방법
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '적립 방법',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: context.textPrimary,
                        ),
                  ),
                  AppSpacing.verticalXxs,
                  Text(
                    '5개 보낼 때마다 1코인',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────
// 코인 충전 섹션
// ─────────────────────────────────────────────────────────────

class _CoinPackageData {
  final String label;
  final int coins;
  final int price;
  final String? savings;
  final bool isRecommended;

  const _CoinPackageData({
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
}

class _CoinChargeSection extends StatelessWidget {
  const _CoinChargeSection();

  static const _packages = [
    _CoinPackageData(
      label: '기본',
      coins: 50,
      price: 4900,
      isRecommended: false,
    ),
    _CoinPackageData(
      label: '인기',
      coins: 120,
      price: 9900,
      savings: '16% 절약',
      isRecommended: true,
    ),
    _CoinPackageData(
      label: '프리미엄',
      coins: 280,
      price: 19900,
      savings: '28% 절약',
      isRecommended: false,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 섹션 제목
        Row(
          children: [
            Text(
              '코인 충전',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: context.textPrimary,
                  ),
            ),
            AppSpacing.horizontalXs,
            const Icon(
              Icons.bolt_rounded,
              color: AppColors.primary,
              size: AppIconSize.md,
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          '더 많이 충전할수록 코인당 가격이 낮아져요',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: context.mutedForegroundColor,
              ),
        ),
        const SizedBox(height: AppSpacing.md),

        // 3개 패키지 카드
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (int i = 0; i < _packages.length; i++) ...[
                if (i > 0) const SizedBox(width: AppSpacing.xs),
                Expanded(child: _PackageCard(package: _packages[i])),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────
// 패키지 카드
// ─────────────────────────────────────────────────────────────

class _PackageCard extends StatelessWidget {
  final _CoinPackageData package;

  const _PackageCard({required this.package});

  void _onTap(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: context.cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
      ),
      builder: (_) => _ChargeConfirmSheet(package: package),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pkg = package;
    return GestureDetector(
      onTap: () => _onTap(context),
      child: Container(
        decoration: _cardDecoration(context, highlighted: pkg.isRecommended),
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [
            // ── 헤더 배너 ──────────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
              color: pkg.isRecommended
                  ? AppColors.primary
                  : context.mutedColor,
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
                      child: Text('🔥', style: TextStyle(fontSize: 12)),
                    ),
                ],
              ),
            ),

            // ── 본문 ───────────────────────────────────────────
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
                        onPressed: () => _onTap(context),
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
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// 충전 확인 바텀시트
// ─────────────────────────────────────────────────────────────

class _ChargeConfirmSheet extends StatelessWidget {
  final _CoinPackageData package;

  const _ChargeConfirmSheet({required this.package});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.xxxl,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 핸들
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Theme.of(context).dividerColor,
              borderRadius: BorderRadius.circular(AppRadius.full),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          // 코인 아이콘
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: context.accentColor,
              shape: BoxShape.circle,
              border: Border.all(color: context.borderColor),
            ),
            child: const Icon(
              Icons.monetization_on_rounded,
              color: AppColors.primary,
              size: AppIconSize.xl,
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // 타이틀
          Text(
            '${package.coins}코인 충전',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: context.textPrimary,
                ),
          ),
          const SizedBox(height: AppSpacing.xs),

          // 가격
          Text(
            package.priceText,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
          ),
          if (package.savings != null) ...[
            const SizedBox(height: AppSpacing.xs),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.xxs,
              ),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppRadius.full),
              ),
              child: Text(
                '기본 패키지 대비 ${package.savings}',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.xl),

          // 안내 메시지
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: context.mutedColor,
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Text(
              '코인 충전 기능은 곧 오픈 예정이에요.\n조금만 기다려주세요! 🎉',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: context.mutedForegroundColor,
                    height: 1.5,
                  ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // 닫기 버튼
          SizedBox(
            width: double.infinity,
            height: 52,
            child: OutlinedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: OutlinedButton.styleFrom(
                foregroundColor: context.textPrimary,
                side: BorderSide(color: context.borderColor),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
              ),
              child: const Text(
                '닫기',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// 코인 안내 카드
// ─────────────────────────────────────────────────────────────

class _CoinInfoCard extends StatelessWidget {
  const _CoinInfoCard();

  static const _infoItems = [
    '보이스 메시지를 5개 보낼 때마다 1코인이 무료로 적립돼요',
    '충전 코인은 리워드 마켓에서 다양하게 사용할 수 있어요',
    '적립 및 충전 코인의 유효기간은 취득일로부터 1년이에요',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: context.accentColor.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: Border.all(color: context.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '🪙 코인 안내',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: context.textPrimary,
                ),
          ),
          AppSpacing.verticalXs,
          ..._infoItems.map(
            (text) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.xxs),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 4),
                    child: Icon(
                      Icons.check_circle_outline_rounded,
                      size: 13,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.xxs),
                  Expanded(
                    child: Text(
                      text,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: context.mutedForegroundColor,
                            height: 1.4,
                          ),
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
