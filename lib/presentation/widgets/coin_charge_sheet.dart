import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:talk_flutter/core/services/iap_service.dart';
import 'package:talk_flutter/core/theme/theme.dart';
import 'package:talk_flutter/presentation/blocs/wallet/wallet_bloc.dart';
import 'package:talk_flutter/presentation/blocs/wallet/wallet_event.dart';
import 'package:talk_flutter/presentation/blocs/wallet/wallet_state.dart';

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
    builder: (_) => BlocProvider.value(
      value: context.read<WalletBloc>(),
      child: const CoinChargeSheet(),
    ),
  );
}

// ─────────────────────────────────────────────────────────────
// 바텀시트 본체
// ─────────────────────────────────────────────────────────────

class CoinChargeSheet extends StatefulWidget {
  const CoinChargeSheet({super.key});

  @override
  State<CoinChargeSheet> createState() => _CoinChargeSheetState();
}

class _CoinChargeSheetState extends State<CoinChargeSheet> {
  IapProduct? _selectedPackage;
  bool _isPurchasing = false;

  @override
  void initState() {
    super.initState();
    _selectedPackage = IapProduct.packages.firstWhere((p) => p.isRecommended,
        orElse: () => IapProduct.packages.first);

    // IAP 서비스가 아직 미초기화인 경우 초기화
    _initIapIfNeeded();
  }

  Future<void> _initIapIfNeeded() async {
    if (!IapService().isAvailable) {
      await IapService().initialize(
        onPurchaseResult: _onIapPurchaseResult,
      );
    }
  }

  void _onIapPurchaseResult(IapPurchaseResult result) {
    if (!mounted) return;

    if (result.success) {
      // 서버에 영수증 전달하여 코인 지급
      final productId = _getBackendProductId(result.productId ?? '');
      if (productId != null) {
        context.read<WalletBloc>().add(WalletIapPurchaseRequested(
              productId: productId,
              platform: Platform.isIOS ? 'ios' : 'android',
              receiptData: result.receiptData,
              purchaseToken: result.purchaseToken,
              transactionId: result.transactionId,
            ));
      }
    } else if (result.error != null && result.error != 'canceled') {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('결제 오류: ${result.error}')),
        );
      }
    }

    if (mounted) setState(() => _isPurchasing = false);
  }

  /// storeProductId → backend product_id 역매핑
  String? _getBackendProductId(String storeProductId) {
    try {
      return IapProduct.packages
          .firstWhere((p) => p.storeProductId == storeProductId)
          .productId;
    } catch (_) {
      return null;
    }
  }

  Future<void> _onPurchaseTap() async {
    final pkg = _selectedPackage;
    if (pkg == null || _isPurchasing) return;

    if (!IapService().isAvailable) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('현재 결제를 사용할 수 없습니다.')),
      );
      return;
    }

    setState(() => _isPurchasing = true);

    // IapService에 callback 재등록 (시트가 열릴 때마다 최신 context 사용)
    await IapService().initialize(onPurchaseResult: _onIapPurchaseResult);
    await IapService().purchase(pkg);

    // 결과는 _onIapPurchaseResult callback에서 처리됨
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<WalletBloc, WalletState>(
      listener: (context, state) {
        if (state.successMessage != null) {
          Navigator.pop(context); // 시트 닫기
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.successMessage!),
              backgroundColor: AppColors.success,
            ),
          );
        }
        if (state.status == WalletStatus.error && state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage!),
              backgroundColor: AppColors.error,
            ),
          );
          setState(() => _isPurchasing = false);
        }
      },
      child: SafeArea(
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
                    for (int i = 0; i < IapProduct.packages.length; i++) ...[
                      if (i > 0) const SizedBox(width: AppSpacing.xs),
                      Expanded(
                        child: _CoinPackageCard(
                          package: IapProduct.packages[i],
                          isSelected:
                              _selectedPackage == IapProduct.packages[i],
                          onTap: () => setState(
                              () => _selectedPackage = IapProduct.packages[i]),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),

              // 충전 버튼
              BlocBuilder<WalletBloc, WalletState>(
                builder: (context, walletState) {
                  final isLoading =
                      _isPurchasing || walletState.isPurchasing;
                  return SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: FilledButton(
                      onPressed: isLoading ? null : _onPurchaseTap,
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor:
                            AppColors.primary.withValues(alpha: 0.6),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(AppRadius.sm),
                        ),
                      ),
                      child: isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              '${_selectedPackage?.priceText ?? ''} 충전하기',
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
                              ),
                            ),
                    ),
                  );
                },
              ),
              const SizedBox(height: AppSpacing.xs),

              // 안내 텍스트
              Text(
                'App Store를 통한 안전한 결제',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: context.mutedForegroundColor,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// 개별 패키지 카드
// ─────────────────────────────────────────────────────────────

class _CoinPackageCard extends StatelessWidget {
  final IapProduct package;
  final bool isSelected;
  final VoidCallback onTap;

  const _CoinPackageCard({
    required this.package,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final pkg = package;
    final highlighted = isSelected || pkg.isRecommended;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        decoration: BoxDecoration(
          color: context.cardColor,
          borderRadius: BorderRadius.circular(AppRadius.lg),
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
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [
            // 헤더 배너
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
              color: highlighted ? AppColors.primary : context.mutedColor,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Text(
                    pkg.name,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: highlighted
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
                          '${pkg.totalCoins}코인',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: pkg.isRecommended ? 16 : 14,
                            fontWeight: FontWeight.w800,
                            color: context.textPrimary,
                          ),
                        ),
                        if (pkg.bonusCoins > 0) ...[
                          const SizedBox(height: 2),
                          Text(
                            '+${pkg.bonusCoins} 보너스',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
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
