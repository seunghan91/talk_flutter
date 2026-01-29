import 'package:flutter_test/flutter_test.dart';
import 'package:talk_flutter/core/enums/app_enums.dart';
import 'package:talk_flutter/data/models/user_model.dart';
import 'package:talk_flutter/domain/entities/user.dart';

void main() {
  group('UserModel', () {
    const testJson = {
      'id': 1,
      'phone_number': '01012345678',
      'nickname': 'TestUser',
      'gender': 'male',
      'profile_image_url': 'https://example.com/avatar.jpg',
      'status': 'active',
      'verified': true,
      'push_enabled': true,
      'broadcast_push_enabled': true,
      'message_push_enabled': false,
      'wallet_balance': 1000,
      'created_at': '2024-01-15T10:30:00Z',
      'updated_at': '2024-01-20T15:45:00Z',
    };

    group('fromJson', () {
      test('parses all fields correctly', () {
        final model = UserModel.fromJson(testJson);

        expect(model.id, equals(1));
        expect(model.phoneNumber, equals('01012345678'));
        expect(model.nickname, equals('TestUser'));
        expect(model.gender, equals('male'));
        expect(model.profileImageUrl, equals('https://example.com/avatar.jpg'));
        expect(model.status, equals('active'));
        expect(model.verified, isTrue);
        expect(model.pushEnabled, isTrue);
        expect(model.broadcastPushEnabled, isTrue);
        expect(model.messagePushEnabled, isFalse);
        expect(model.walletBalance, equals(1000));
        expect(model.createdAt, equals('2024-01-15T10:30:00Z'));
        expect(model.updatedAt, equals('2024-01-20T15:45:00Z'));
      });

      test('handles null optional fields', () {
        final minimalJson = {'id': 1};
        final model = UserModel.fromJson(minimalJson);

        expect(model.id, equals(1));
        expect(model.phoneNumber, isNull);
        expect(model.nickname, isNull);
        expect(model.gender, isNull);
        expect(model.profileImageUrl, isNull);
        expect(model.verified, isNull);
      });
    });

    group('toJson', () {
      test('serializes all fields correctly', () {
        const model = UserModel(
          id: 1,
          phoneNumber: '01012345678',
          nickname: 'TestUser',
          gender: 'male',
          verified: true,
        );

        final json = model.toJson();

        expect(json['id'], equals(1));
        expect(json['phone_number'], equals('01012345678'));
        expect(json['nickname'], equals('TestUser'));
        expect(json['gender'], equals('male'));
        expect(json['verified'], isTrue);
      });
    });

    group('toEntity', () {
      test('converts to User entity correctly', () {
        final model = UserModel.fromJson(testJson);
        final entity = model.toEntity();

        expect(entity, isA<User>());
        expect(entity.id, equals(1));
        expect(entity.phoneNumber, equals('01012345678'));
        expect(entity.nickname, equals('TestUser'));
        expect(entity.gender, equals(Gender.male));
        expect(entity.status, equals(UserStatus.active));
        expect(entity.verified, isTrue);
        expect(entity.walletBalance, equals(1000));
      });

      test('handles missing optional fields with defaults', () {
        const model = UserModel(id: 1);
        final entity = model.toEntity();

        expect(entity.id, equals(1));
        expect(entity.nickname, equals('User')); // Default
        expect(entity.gender, equals(Gender.unknown)); // Default
        expect(entity.status, equals(UserStatus.active)); // Default
        expect(entity.verified, isFalse); // Default
        expect(entity.pushEnabled, isTrue); // Default
      });
    });

    group('fromEntity', () {
      test('creates model from entity correctly', () {
        final entity = User(
          id: 1,
          phoneNumber: '01012345678',
          nickname: 'TestUser',
          gender: Gender.female,
          status: UserStatus.active,
          verified: true,
          createdAt: DateTime(2024, 1, 15),
        );

        final model = UserModel.fromEntity(entity);

        expect(model.id, equals(1));
        expect(model.phoneNumber, equals('01012345678'));
        expect(model.nickname, equals('TestUser'));
        expect(model.gender, equals('female'));
        expect(model.status, equals('active'));
        expect(model.verified, isTrue);
      });
    });

    group('round-trip conversion', () {
      test('entity -> model -> entity preserves data', () {
        final originalEntity = User(
          id: 1,
          phoneNumber: '01012345678',
          nickname: 'TestUser',
          gender: Gender.male,
          status: UserStatus.active,
          verified: true,
          pushEnabled: true,
          walletBalance: 500,
          createdAt: DateTime(2024, 1, 15),
        );

        final model = UserModel.fromEntity(originalEntity);
        final restoredEntity = model.toEntity();

        expect(restoredEntity.id, equals(originalEntity.id));
        expect(restoredEntity.phoneNumber, equals(originalEntity.phoneNumber));
        expect(restoredEntity.nickname, equals(originalEntity.nickname));
        expect(restoredEntity.gender, equals(originalEntity.gender));
        expect(restoredEntity.status, equals(originalEntity.status));
        expect(restoredEntity.verified, equals(originalEntity.verified));
        expect(restoredEntity.walletBalance, equals(originalEntity.walletBalance));
      });

      test('json -> model -> json preserves data', () {
        final model = UserModel.fromJson(testJson);
        final json = model.toJson();
        final restoredModel = UserModel.fromJson(json);

        expect(restoredModel.id, equals(model.id));
        expect(restoredModel.phoneNumber, equals(model.phoneNumber));
        expect(restoredModel.nickname, equals(model.nickname));
        expect(restoredModel.gender, equals(model.gender));
        expect(restoredModel.verified, equals(model.verified));
      });
    });
  });
}
