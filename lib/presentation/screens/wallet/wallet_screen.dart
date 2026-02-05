import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:talk_flutter/core/theme/theme.dart';
import 'package:talk_flutter/domain/entities/wallet.dart';
import 'package:talk_flutter/presentation/blocs/wallet/wallet_bloc.dart';
import 'package:talk_flutter/presentation/blocs/wallet/wallet_event.dart';
import 'package:talk_flutter/presentation/blocs/wallet/wallet_state.dart';

/// Wallet screen
class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  @override
  void initState() {
    super.initState();
    context.read<WalletBloc>().add(const WalletRequested());
    context.read<WalletBloc>().add(const WalletTransactionsRequested());
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('지갑'),
      ),
      body: SafeArea(
        child: BlocConsumer<WalletBloc, WalletState>(
          listener: (context, state) {
            if (state.successMessage != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.successMessage!)),
              );
            } else if (state.hasError && state.errorMessage != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.errorMessage!),
                  backgroundColor: colorScheme.error,
                ),
              );
            }
          },
          builder: (context, state) {
            if (state.isLoading && !state.hasWallet) {
              return const Center(child: CircularProgressIndicator());
            }

            return RefreshIndicator(
              onRefresh: () async {
                context.read<WalletBloc>().add(const WalletRequested());
                context.read<WalletBloc>().add(const WalletTransactionsRequested());
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  children: [
                    // Balance Card
                    _BalanceCard(
                      balance: state.formattedBalance,
                      onDeposit: () => _showDepositDialog(context),
                    ),
                    AppSpacing.verticalXl,

                    // Transaction History
                    Padding(
                      padding: AppSpacing.screenHorizontal,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '거래 내역',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          AppSpacing.verticalSm,
                          if (state.transactions.isEmpty)
                            _buildEmptyTransactions()
                          else
                            ...state.transactions.map((tx) => _TransactionTile(transaction: tx)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildEmptyTransactions() {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxl),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: AppIconSize.xxl,
              color: colorScheme.onSurfaceVariant,
            ),
            AppSpacing.verticalSm,
            Text(
              '거래 내역이 없습니다',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDepositDialog(BuildContext context) {
    final amountController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('충전'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: '충전 금액',
                prefixText: '\u20a9 ',
                border: OutlineInputBorder(),
              ),
            ),
            AppSpacing.verticalMd,
            Wrap(
              spacing: AppSpacing.xs,
              children: [5000, 10000, 30000, 50000].map((amount) {
                return ActionChip(
                  label: Text('\u20a9${_formatNumber(amount)}'),
                  onPressed: () {
                    amountController.text = amount.toString();
                  },
                );
              }).toList(),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          FilledButton(
            onPressed: () {
              final amount = double.tryParse(amountController.text);
              if (amount != null && amount > 0) {
                context.read<WalletBloc>().add(
                      WalletDepositRequested(amount: amount),
                    );
                Navigator.pop(context);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('올바른 금액을 입력해주세요')),
                );
              }
            },
            child: const Text('충전'),
          ),
        ],
      ),
    );
  }

  String _formatNumber(int number) {
    return number.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        );
  }
}

class _BalanceCard extends StatelessWidget {
  final String balance;
  final VoidCallback onDeposit;

  const _BalanceCard({
    required this.balance,
    required this.onDeposit,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      margin: AppSpacing.screenPadding,
      padding: AppSpacing.dialogPadding,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colorScheme.primary,
            colorScheme.secondary,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: AppRadius.largeRadius,
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withValues(alpha: 0.3),
            blurRadius: AppSpacing.sm,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '잔액',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onPrimary.withValues(alpha: 0.8),
                ),
          ),
          AppSpacing.verticalXs,
          Text(
            balance,
            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  color: colorScheme.onPrimary,
                  fontWeight: FontWeight.bold,
                ),
          ),
          AppSpacing.verticalXl,
          SizedBox(
            width: double.infinity,
            child: FilledButton.tonal(
              onPressed: onDeposit,
              style: FilledButton.styleFrom(
                backgroundColor: colorScheme.onPrimary,
                foregroundColor: colorScheme.primary,
              ),
              child: const Text('충전하기'),
            ),
          ),
        ],
      ),
    );
  }
}

class _TransactionTile extends StatelessWidget {
  final WalletTransaction transaction;

  const _TransactionTile({required this.transaction});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isPositive = transaction.isDeposit;
    final positiveColor = Colors.green;
    final negativeColor = Colors.red;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: isPositive
                ? positiveColor.withValues(alpha: 0.1)
                : negativeColor.withValues(alpha: 0.1),
            child: Icon(
              isPositive ? Icons.add : Icons.remove,
              color: isPositive ? positiveColor : negativeColor,
            ),
          ),
          AppSpacing.horizontalSm,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.typeKorean,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                ),
                if (transaction.description != null)
                  Text(
                    transaction.description!,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                  ),
                Text(
                  transaction.formattedDate ?? _formatDate(transaction.createdAt),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                ),
              ],
            ),
          ),
          Text(
            '${isPositive ? '+' : '-'}${transaction.formattedAmount}',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: isPositive ? positiveColor : negativeColor,
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')}';
  }
}
