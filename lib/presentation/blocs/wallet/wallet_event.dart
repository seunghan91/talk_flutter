import 'package:equatable/equatable.dart';

/// Wallet events
abstract class WalletEvent extends Equatable {
  const WalletEvent();

  @override
  List<Object?> get props => [];
}

/// Request wallet information
class WalletRequested extends WalletEvent {
  const WalletRequested();
}

/// Request transaction history
class WalletTransactionsRequested extends WalletEvent {
  final bool refresh;

  const WalletTransactionsRequested({this.refresh = false});

  @override
  List<Object?> get props => [refresh];
}

/// Request deposit
class WalletDepositRequested extends WalletEvent {
  final double amount;
  final String? paymentMethod;

  const WalletDepositRequested({
    required this.amount,
    this.paymentMethod,
  });

  @override
  List<Object?> get props => [amount, paymentMethod];
}

/// Clear wallet state
class WalletCleared extends WalletEvent {
  const WalletCleared();
}

/// IAP 구매 완료 후 서버에 영수증 전달
class WalletIapPurchaseRequested extends WalletEvent {
  final String productId;      // 백엔드 product_id (e.g. cash_100)
  final String? receiptData;   // iOS 영수증 (base64)
  final String? purchaseToken; // Android 구매 토큰
  final String? transactionId;
  final String platform;       // 'ios' | 'android'

  const WalletIapPurchaseRequested({
    required this.productId,
    this.receiptData,
    this.purchaseToken,
    this.transactionId,
    required this.platform,
  });

  @override
  List<Object?> get props => [productId, receiptData, purchaseToken, transactionId, platform];
}
