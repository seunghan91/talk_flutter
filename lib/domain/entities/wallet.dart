import 'package:equatable/equatable.dart';

/// Wallet entity - Domain layer
class Wallet extends Equatable {
  final int balance;
  final int transactionCount;
  final String formattedBalance;

  const Wallet({
    required this.balance,
    this.transactionCount = 0,
    required this.formattedBalance,
  });

  Wallet copyWith({
    int? balance,
    int? transactionCount,
    String? formattedBalance,
  }) {
    return Wallet(
      balance: balance ?? this.balance,
      transactionCount: transactionCount ?? this.transactionCount,
      formattedBalance: formattedBalance ?? this.formattedBalance,
    );
  }

  @override
  List<Object?> get props => [balance, transactionCount, formattedBalance];
}

/// Wallet transaction entity
class WalletTransaction extends Equatable {
  final int id;
  final String type;
  final String typeKorean;
  final int amount;
  final String formattedAmount;
  final String? description;
  final String? paymentMethod;
  final String status;
  final DateTime createdAt;
  final String? formattedDate;

  const WalletTransaction({
    required this.id,
    required this.type,
    required this.typeKorean,
    required this.amount,
    required this.formattedAmount,
    this.description,
    this.paymentMethod,
    required this.status,
    required this.createdAt,
    this.formattedDate,
  });

  /// Check if transaction is deposit
  bool get isDeposit => type == 'deposit';

  /// Check if transaction is withdrawal
  bool get isWithdrawal => type == 'withdrawal';

  /// Check if transaction is purchase
  bool get isPurchase => type == 'purchase';

  WalletTransaction copyWith({
    int? id,
    String? type,
    String? typeKorean,
    int? amount,
    String? formattedAmount,
    String? description,
    String? paymentMethod,
    String? status,
    DateTime? createdAt,
    String? formattedDate,
  }) {
    return WalletTransaction(
      id: id ?? this.id,
      type: type ?? this.type,
      typeKorean: typeKorean ?? this.typeKorean,
      amount: amount ?? this.amount,
      formattedAmount: formattedAmount ?? this.formattedAmount,
      description: description ?? this.description,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      formattedDate: formattedDate ?? this.formattedDate,
    );
  }

  @override
  List<Object?> get props => [
        id,
        type,
        typeKorean,
        amount,
        formattedAmount,
        description,
        paymentMethod,
        status,
        createdAt,
        formattedDate,
      ];
}
