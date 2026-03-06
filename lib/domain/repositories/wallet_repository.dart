import 'package:talk_flutter/domain/entities/wallet.dart';

/// Wallet repository interface - Domain layer
abstract class WalletRepository {
  /// Get wallet information
  Future<Wallet> getWallet();

  /// Get recent transactions
  Future<List<WalletTransaction>> getTransactions();

  /// Deposit money into wallet
  Future<DepositResult> deposit({
    required double amount,
    String? paymentMethod,
  });

  /// IAP 영수증을 서버에 전달하고 코인을 지급받음
  Future<IapPurchaseResult> purchaseIap({
    required String productId,
    required String platform,
    String? receiptData,
    String? purchaseToken,
    String? transactionId,
  });
}

/// Deposit result
class DepositResult {
  final bool success;
  final String message;
  final int balance;
  final WalletTransaction? transaction;

  const DepositResult({
    required this.success,
    required this.message,
    required this.balance,
    this.transaction,
  });
}
/// IAP 구매 후 서버에 영수증 전달하여 코인 지급받는 결과
class IapPurchaseResult {
  final bool success;
  final String message;
  final int balance;
  final int coinsAdded;

  const IapPurchaseResult({
    required this.success,
    required this.message,
    required this.balance,
    this.coinsAdded = 0,
  });
}

