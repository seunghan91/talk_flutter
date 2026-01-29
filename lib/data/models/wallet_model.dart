import 'package:json_annotation/json_annotation.dart';
import 'package:talk_flutter/domain/entities/wallet.dart';

part 'wallet_model.g.dart';

/// Wallet DTO for API communication
@JsonSerializable()
class WalletModel {
  final int balance;
  @JsonKey(name: 'transaction_count')
  final int? transactionCount;
  @JsonKey(name: 'formatted_balance')
  final String? formattedBalance;

  const WalletModel({
    required this.balance,
    this.transactionCount,
    this.formattedBalance,
  });

  factory WalletModel.fromJson(Map<String, dynamic> json) =>
      _$WalletModelFromJson(json);

  Map<String, dynamic> toJson() => _$WalletModelToJson(this);

  /// Convert to domain entity
  Wallet toEntity() {
    return Wallet(
      balance: balance,
      transactionCount: transactionCount ?? 0,
      formattedBalance: formattedBalance ?? '$balance원',
    );
  }
}

/// Wallet transaction DTO for API communication
@JsonSerializable()
class WalletTransactionModel {
  final int id;
  final String type;
  @JsonKey(name: 'type_korean')
  final String? typeKorean;
  final int amount;
  @JsonKey(name: 'formatted_amount')
  final String? formattedAmount;
  final String? description;
  @JsonKey(name: 'payment_method')
  final String? paymentMethod;
  final String status;
  @JsonKey(name: 'created_at')
  final String? createdAt;
  @JsonKey(name: 'formatted_date')
  final String? formattedDate;

  const WalletTransactionModel({
    required this.id,
    required this.type,
    this.typeKorean,
    required this.amount,
    this.formattedAmount,
    this.description,
    this.paymentMethod,
    required this.status,
    this.createdAt,
    this.formattedDate,
  });

  factory WalletTransactionModel.fromJson(Map<String, dynamic> json) =>
      _$WalletTransactionModelFromJson(json);

  Map<String, dynamic> toJson() => _$WalletTransactionModelToJson(this);

  /// Convert to domain entity
  WalletTransaction toEntity() {
    return WalletTransaction(
      id: id,
      type: type,
      typeKorean: typeKorean ?? _getTypeKorean(type),
      amount: amount,
      formattedAmount: formattedAmount ?? '$amount원',
      description: description,
      paymentMethod: paymentMethod,
      status: status,
      createdAt: _parseDateTime(createdAt) ?? DateTime.now(),
      formattedDate: formattedDate,
    );
  }

  static String _getTypeKorean(String type) {
    return switch (type) {
      'deposit' => '충전',
      'withdrawal' => '출금',
      'purchase' => '구매',
      'refund' => '환불',
      _ => type,
    };
  }

  static DateTime? _parseDateTime(String? value) {
    if (value == null || value.isEmpty) return null;
    try {
      return DateTime.parse(value);
    } catch (_) {
      return null;
    }
  }
}
