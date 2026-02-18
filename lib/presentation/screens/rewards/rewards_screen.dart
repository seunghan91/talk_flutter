import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:talk_flutter/core/theme/theme.dart';

/// Rewards screen mapped from design IA.
class RewardsScreen extends StatelessWidget {
  const RewardsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('리워드'),
      ),
      body: ListView(
        padding: AppSpacing.screenPadding,
        children: [
          Card(
            child: Padding(
              padding: AppSpacing.cardPadding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '리워드 센터',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  AppSpacing.verticalXs,
                  Text(
                    '출석, 미션, 이벤트로 코인을 얻을 수 있어요.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textTertiaryLight,
                        ),
                  ),
                  AppSpacing.verticalMd,
                  OutlinedButton.icon(
                    onPressed: () => context.push('/wallet'),
                    icon: const Icon(Icons.monetization_on_outlined),
                    label: const Text('내 코인 확인'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
