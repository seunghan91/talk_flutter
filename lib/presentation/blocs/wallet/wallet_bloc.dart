import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:talk_flutter/domain/repositories/wallet_repository.dart';
import 'package:talk_flutter/presentation/blocs/wallet/wallet_event.dart';
import 'package:talk_flutter/presentation/blocs/wallet/wallet_state.dart';

/// Wallet BLoC
class WalletBloc extends Bloc<WalletEvent, WalletState> {
  final WalletRepository _walletRepository;

  WalletBloc({
    required WalletRepository walletRepository,
  })  : _walletRepository = walletRepository,
        super(const WalletState()) {
    on<WalletRequested>(_onWalletRequested);
    on<WalletTransactionsRequested>(_onTransactionsRequested);
    on<WalletDepositRequested>(_onDepositRequested);
    on<WalletCleared>(_onCleared);
  }

  Future<void> _onWalletRequested(
    WalletRequested event,
    Emitter<WalletState> emit,
  ) async {
    try {
      emit(state.copyWith(status: WalletStatus.loading));

      final wallet = await _walletRepository.getWallet();

      emit(state.copyWith(
        status: WalletStatus.loaded,
        wallet: wallet,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: WalletStatus.error,
        errorMessage: '지갑 정보를 불러올 수 없습니다.',
      ));
    }
  }

  Future<void> _onTransactionsRequested(
    WalletTransactionsRequested event,
    Emitter<WalletState> emit,
  ) async {
    try {
      emit(state.copyWith(status: WalletStatus.loading));

      final transactions = await _walletRepository.getTransactions();

      emit(state.copyWith(
        status: WalletStatus.loaded,
        transactions: transactions,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: WalletStatus.error,
        errorMessage: '거래 내역을 불러올 수 없습니다.',
      ));
    }
  }

  Future<void> _onDepositRequested(
    WalletDepositRequested event,
    Emitter<WalletState> emit,
  ) async {
    try {
      emit(state.copyWith(status: WalletStatus.depositing));

      final result = await _walletRepository.deposit(
        amount: event.amount,
        paymentMethod: event.paymentMethod,
      );

      if (result.success) {
        // Refresh wallet after deposit
        final wallet = await _walletRepository.getWallet();

        emit(state.copyWith(
          status: WalletStatus.loaded,
          wallet: wallet,
          successMessage: result.message,
        ));
      } else {
        emit(state.copyWith(
          status: WalletStatus.error,
          errorMessage: result.message,
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        status: WalletStatus.error,
        errorMessage: '충전에 실패했습니다.',
      ));
    }
  }

  void _onCleared(
    WalletCleared event,
    Emitter<WalletState> emit,
  ) {
    emit(const WalletState());
  }
}
