import 'package:flutter_test/flutter_test.dart';
import 'package:talk_flutter/domain/entities/broadcast.dart';

void main() {
  group('Broadcast', () {
    test('isActive returns true when not expired', () {
      final broadcast = Broadcast(
        id: 1,
        userId: 1,
        isExpired: false,
        expiredAt: DateTime.now().add(const Duration(hours: 48)),
        createdAt: DateTime.now(),
      );
      expect(broadcast.isActive, isTrue);
    });

    test('isActive returns false when expired', () {
      final broadcast = Broadcast(
        id: 1,
        userId: 1,
        isExpired: true,
        createdAt: DateTime.now(),
      );
      expect(broadcast.isActive, isFalse);
    });

    test('isActive returns false when expiredAt is in the past', () {
      final broadcast = Broadcast(
        id: 1,
        userId: 1,
        isExpired: false,
        expiredAt: DateTime.now().subtract(const Duration(hours: 1)),
        createdAt: DateTime.now(),
      );
      expect(broadcast.isActive, isFalse);
    });

    test('isExpiringSoon returns true within 24 hours', () {
      final broadcast = Broadcast(
        id: 1,
        userId: 1,
        expiredAt: DateTime.now().add(const Duration(hours: 12)),
        createdAt: DateTime.now(),
      );
      expect(broadcast.isExpiringSoon, isTrue);
    });

    test('isExpiringSoon returns false when more than 24 hours', () {
      final broadcast = Broadcast(
        id: 1,
        userId: 1,
        expiredAt: DateTime.now().add(const Duration(hours: 48)),
        createdAt: DateTime.now(),
      );
      expect(broadcast.isExpiringSoon, isFalse);
    });

    test('formattedDuration formats correctly', () {
      final broadcast = Broadcast(
        id: 1,
        userId: 1,
        duration: 125,
        createdAt: DateTime.now(),
      );
      expect(broadcast.formattedDuration, '2:05');
    });

    test('formattedDuration returns 0:00 when null', () {
      final broadcast = Broadcast(
        id: 1,
        userId: 1,
        duration: null,
        createdAt: DateTime.now(),
      );
      expect(broadcast.formattedDuration, '0:00');
    });

    test('copyWith creates new instance with updated fields', () {
      final original = Broadcast(
        id: 1,
        userId: 1,
        isListened: false,
        createdAt: DateTime.now(),
      );
      final updated = original.copyWith(isListened: true);

      expect(updated.isListened, isTrue);
      expect(updated.id, original.id);
      expect(original.isListened, isFalse);
    });

    test('equatable comparison works', () {
      final now = DateTime(2024, 1, 1);
      final a = Broadcast(id: 1, userId: 1, createdAt: now);
      final b = Broadcast(id: 1, userId: 1, createdAt: now);
      expect(a, equals(b));
    });
  });
}
