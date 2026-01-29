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
