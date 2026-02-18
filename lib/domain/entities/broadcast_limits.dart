import 'package:equatable/equatable.dart';

/// Broadcast sending limits exposed by backend.
class BroadcastLimits extends Equatable {
  final int dailyLimit;
  final int dailyUsed;
  final int dailyRemaining;
  final int? hourlyLimit;
  final int? hourlyUsed;
  final bool canBroadcast;
  final DateTime? nextResetAt;
  final DateTime? cooldownEndsAt;

  const BroadcastLimits({
    required this.dailyLimit,
    required this.dailyUsed,
    required this.dailyRemaining,
    required this.canBroadcast,
    this.hourlyLimit,
    this.hourlyUsed,
    this.nextResetAt,
    this.cooldownEndsAt,
  });

  factory BroadcastLimits.fallback({
    int dailyLimit = 20,
  }) {
    return BroadcastLimits(
      dailyLimit: dailyLimit,
      dailyUsed: 0,
      dailyRemaining: dailyLimit,
      canBroadcast: true,
    );
  }

  @override
  List<Object?> get props => [
        dailyLimit,
        dailyUsed,
        dailyRemaining,
        hourlyLimit,
        hourlyUsed,
        canBroadcast,
        nextResetAt,
        cooldownEndsAt,
      ];
}
