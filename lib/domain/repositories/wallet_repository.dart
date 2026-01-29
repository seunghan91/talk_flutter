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
