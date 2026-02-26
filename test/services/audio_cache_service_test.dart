import 'package:flutter_test/flutter_test.dart';
import 'package:talk_flutter/domain/entities/broadcast_limits.dart';

void main() {
  group('BroadcastLimits', () {
    test('creates with required fields', () {
      const limits = BroadcastLimits(
        dailyLimit: 20,
        dailyUsed: 5,
        dailyRemaining: 15,
        canBroadcast: true,
      );
      expect(limits.dailyLimit, 20);
      expect(limits.dailyUsed, 5);
      expect(limits.dailyRemaining, 15);
      expect(limits.canBroadcast, isTrue);
    });

    test('fallback creates default limits', () {
      final limits = BroadcastLimits.fallback(dailyLimit: 10);
      expect(limits.dailyLimit, 10);
      expect(limits.dailyUsed, 0);
      expect(limits.dailyRemaining, 10);
      expect(limits.canBroadcast, isTrue);
    });

    test('equatable comparison works', () {
      const a = BroadcastLimits(
        dailyLimit: 20,
        dailyUsed: 0,
        dailyRemaining: 20,
        canBroadcast: true,
      );
      const b = BroadcastLimits(
        dailyLimit: 20,
        dailyUsed: 0,
        dailyRemaining: 20,
        canBroadcast: true,
      );
      expect(a, equals(b));
    });
  });
}
