import 'dart:async';
import 'dart:io';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:logger/logger.dart';

/// IAP 결과 콜백
typedef IapPurchaseCallback = void Function(IapPurchaseResult result);

/// IAP 구매 결과
class IapPurchaseResult {
  final bool success;
  final String? productId;
  final String? purchaseToken; // Android
  final String? receiptData;   // iOS (base64)
  final String? transactionId;
  final String? error;

  const IapPurchaseResult({
    required this.success,
    this.productId,
    this.purchaseToken,
    this.receiptData,
    this.transactionId,
    this.error,
  });
}

/// 결제 상품 정보 (백엔드 매핑용)
class IapProduct {
  final String productId;        // 백엔드 product_id (e.g. cash_100)
  final String storeProductId;   // 스토어 ID (e.g. com.talkapp.talkk2025.cash_100)
  final String name;
  final int coins;
  final int bonusCoins;
  final int price;
  final String? savings;
  final bool isRecommended;

  const IapProduct({
    required this.productId,
    required this.storeProductId,
    required this.name,
    required this.coins,
    this.bonusCoins = 0,
    required this.price,
    this.savings,
    this.isRecommended = false,
  });

  int get totalCoins => coins + bonusCoins;

  String get priceText {
    final formatted = price.toString().replaceAllMapped(
          RegExp(r'(\d)(?=(\d{3})+$)'),
          (m) => '${m[1]},',
        );
    return '₩$formatted';
  }

  /// 앱에서 제공하는 3개 패키지 (백엔드 seed와 일치)
  static const List<IapProduct> packages = [
    IapProduct(
      productId: 'cash_100',
      storeProductId: 'com.talkapp.talkk2025.cash_100',
      name: '기본',
      coins: 100,
      price: 1100,
    ),
    IapProduct(
      productId: 'cash_1000',
      storeProductId: 'com.talkapp.talkk2025.cash_1000',
      name: '인기',
      coins: 1000,
      bonusCoins: 50,
      price: 11000,
      savings: '5% 보너스',
      isRecommended: true,
    ),
    IapProduct(
      productId: 'cash_5000',
      storeProductId: 'com.talkapp.talkk2025.cash_5000',
      name: '프리미엄',
      coins: 5000,
      bonusCoins: 750,
      price: 55000,
      savings: '15% 보너스',
    ),
  ];
}

/// In-App Purchase 서비스
/// iOS StoreKit / Android Google Play를 단일 인터페이스로 래핑
class IapService {
  static final IapService _instance = IapService._internal();
  factory IapService() => _instance;
  IapService._internal();

  final _logger = Logger();
  final InAppPurchase _iap = InAppPurchase.instance;

  StreamSubscription<List<PurchaseDetails>>? _subscription;
  IapPurchaseCallback? _onPurchaseResult;

  bool _isAvailable = false;
  bool get isAvailable => _isAvailable;

  /// IAP 초기화 - 앱 시작 시 1회 호출
  Future<void> initialize({IapPurchaseCallback? onPurchaseResult}) async {
    _onPurchaseResult = onPurchaseResult;
    _isAvailable = await _iap.isAvailable();

    if (!_isAvailable) {
      _logger.w('[IAP] Store not available');
      return;
    }

    // 구매 스트림 구독
    _subscription = _iap.purchaseStream.listen(
      _onPurchaseUpdated,
      onError: (e) => _logger.e('[IAP] Purchase stream error: $e'),
    );

    // 미처리 구매 복원 (앱 재시작 시)
    await _iap.restorePurchases();

    _logger.i('[IAP] Initialized successfully');
  }

  /// 특정 상품 구매 시작
  Future<bool> purchase(IapProduct product) async {
    if (!_isAvailable) {
      _logger.w('[IAP] Store not available');
      return false;
    }

    final storeProductIds = {product.storeProductId};
    final response = await _iap.queryProductDetails(storeProductIds);

    if (response.error != null || response.productDetails.isEmpty) {
      _logger.e('[IAP] Product not found: ${product.storeProductId}');
      _onPurchaseResult?.call(IapPurchaseResult(
        success: false,
        productId: product.productId,
        error: '상품 정보를 불러올 수 없습니다.',
      ));
      return false;
    }

    final productDetail = response.productDetails.first;
    final purchaseParam = PurchaseParam(productDetails: productDetail);

    try {
      return await _iap.buyConsumable(purchaseParam: purchaseParam);
    } catch (e) {
      _logger.e('[IAP] Purchase failed: $e');
      return false;
    }
  }

  /// 구매 스트림 처리
  void _onPurchaseUpdated(List<PurchaseDetails> purchases) {
    for (final purchase in purchases) {
      _handlePurchase(purchase);
    }
  }

  Future<void> _handlePurchase(PurchaseDetails purchase) async {
    if (purchase.status == PurchaseStatus.pending) {
      _logger.i('[IAP] Purchase pending: ${purchase.productID}');
      return;
    }

    if (purchase.status == PurchaseStatus.error) {
      _logger.e('[IAP] Purchase error: ${purchase.error?.message}');
      _onPurchaseResult?.call(IapPurchaseResult(
        success: false,
        productId: purchase.productID,
        error: purchase.error?.message ?? '결제에 실패했습니다.',
      ));
      await _iap.completePurchase(purchase);
      return;
    }

    if (purchase.status == PurchaseStatus.canceled) {
      _logger.i('[IAP] Purchase canceled: ${purchase.productID}');
      _onPurchaseResult?.call(IapPurchaseResult(
        success: false,
        productId: purchase.productID,
        error: 'canceled',
      ));
      await _iap.completePurchase(purchase);
      return;
    }

    if (purchase.status == PurchaseStatus.purchased ||
        purchase.status == PurchaseStatus.restored) {
      // 영수증 추출
      final receiptData = _extractReceiptData(purchase);
      final transactionId = purchase.purchaseID;

      _logger.i('[IAP] Purchase success: ${purchase.productID}');

      _onPurchaseResult?.call(IapPurchaseResult(
        success: true,
        productId: purchase.productID,
        receiptData: receiptData,
        transactionId: transactionId,
        purchaseToken: Platform.isAndroid
            ? purchase.verificationData.serverVerificationData
            : null,
      ));

      // 구매 완료 처리 (서버 검증 후 호출해야 하지만,
      // consumable은 즉시 완료해야 재구매 가능)
      await _iap.completePurchase(purchase);
    }
  }

  String? _extractReceiptData(PurchaseDetails purchase) {
    if (Platform.isIOS) {
      return purchase.verificationData.serverVerificationData;
    }
    return null;
  }

  /// 리소스 정리
  void dispose() {
    _subscription?.cancel();
    _subscription = null;
  }
}
