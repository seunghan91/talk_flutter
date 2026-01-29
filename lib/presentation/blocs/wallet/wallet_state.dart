import 'package:equatable/equatable.dart';
import 'package:talk_flutter/domain/entities/wallet.dart';

/// Wallet state status
enum WalletStatus { initial, loading, loaded, depositing, error }

/// Wallet state
class WalletState extends Equatable {
  final WalletStatus status;
  final Wallet? wallet;
  final List<WalletTransaction> transactions;
  final String? errorMessage;
  final String? successMessage;

  const WalletState({
    this.status = WalletStatus.initial,
    this.wallet,
    this.transactions = const [],
    this.errorMessage,
    this.successMessage,
  });

  bool get isLoading => status == WalletStatus.loading;
  bool get isDepositing => status == WalletStatus.depositing;
  bool get hasError => errorMessage != null;
  bool get hasWallet => wallet != null;

  int get balance => wallet?.balance ?? 0;
  String get formattedBalance => wallet?.formattedBalance ?? '₩0';

  WalletState copyWith({
    WalletStatus? status,
    Wallet? wallet,
    List<WalletTransaction>? transactions,
    String? errorMessage,
    String? successMessage,
  }) {
    return WalletState(
      status: status ?? this.status,
      wallet: wallet ?? this.wallet,
      transactions: transactions ?? this.transactions,
      errorMessage: errorMessage,
      successMessage: successMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        wallet,
        transactions,
        errorMessage,
        successMessage,
      ];
}
