import 'package:talk_flutter/data/datasources/remote/api_client.dart';
import 'package:talk_flutter/domain/entities/wallet.dart';
import 'package:talk_flutter/domain/repositories/wallet_repository.dart';

/// Wallet repository implementation
class WalletRepositoryImpl implements WalletRepository {
  final ApiClient _apiClient;

  WalletRepositoryImpl({
    required ApiClient apiClient,
  }) : _apiClient = apiClient;

  @override
  Future<Wallet> getWallet() async {
    final response = await _apiClient.getMyWallet();
    final data = response.data as Map<String, dynamic>? ?? {};

    return Wallet(
      balance: data['balance'] as int? ?? 0,
      transactionCount: data['transaction_count'] as int? ?? 0,
      formattedBalance: data['formatted_balance'] as String? ?? '₩0',
    );
  }

  @override
  Future<List<WalletTransaction>> getTransactions() async {
    final response = await _apiClient.getWalletTransactions();
    final data = response.data as List<dynamic>? ?? [];

    return data
        .map((json) => _parseTransaction(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<DepositResult> deposit({
    required double amount,
    String? paymentMethod,
  }) async {
    final body = <String, dynamic>{
      'amount': amount,
      if (paymentMethod != null) 'payment_method': paymentMethod,
    };

    final response = await _apiClient.depositToWallet(body);
    final data = response.data as Map<String, dynamic>? ?? {};

    final success = data['success'] as bool? ?? false;
    final message = data['message'] as String? ?? '';
    final balance = data['balance'] as int? ?? 0;
    final transactionData = data['transaction'] as Map<String, dynamic>?;

    return DepositResult(
      success: success,
      message: message,
      balance: balance,
      transaction:
          transactionData != null ? _parseTransaction(transactionData) : null,
    );
  }

  /// Parse transaction data from API response
  WalletTransaction _parseTransaction(Map<String, dynamic> data) {
    return WalletTransaction(
      id: data['id'] as int,
      type: data['type'] as String? ?? 'unknown',
      typeKorean: data['type_korean'] as String? ?? '알 수 없음',
      amount: data['amount'] as int? ?? 0,
      formattedAmount: data['formatted_amount'] as String? ?? '₩0',
      description: data['description'] as String?,
      paymentMethod: data['payment_method'] as String?,
      status: data['status'] as String? ?? 'unknown',
      createdAt: DateTime.parse(
        data['created_at'] as String? ?? DateTime.now().toIso8601String(),
      ),
      formattedDate: data['formatted_date'] as String?,
    );
  }
}
