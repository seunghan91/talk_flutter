import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:talk_flutter/core/services/connectivity_service.dart';

class MockConnectivity extends Mock implements Connectivity {}

void main() {
  late MockConnectivity mockConnectivity;
  late StreamController<ConnectivityResult> streamController;

  setUp(() {
    mockConnectivity = MockConnectivity();
    streamController = StreamController<ConnectivityResult>.broadcast();
    when(() => mockConnectivity.onConnectivityChanged)
        .thenAnswer((_) => streamController.stream);
  });

  tearDown(() async {
    await streamController.close();
  });

  group('ConnectivityService', () {
    test('initializes as online when wifi is available', () async {
      when(() => mockConnectivity.checkConnectivity())
          .thenAnswer((_) async => ConnectivityResult.wifi);

      final service = ConnectivityService(connectivity: mockConnectivity);
      await service.initialize();

      expect(service.isOnline, isTrue);
      await service.dispose();
    });

    test('initializes as offline when no connectivity', () async {
      when(() => mockConnectivity.checkConnectivity())
          .thenAnswer((_) async => ConnectivityResult.none);

      final service = ConnectivityService(connectivity: mockConnectivity);
      await service.initialize();

      expect(service.isOnline, isFalse);
      await service.dispose();
    });

    test('emits false when connectivity is lost', () async {
      when(() => mockConnectivity.checkConnectivity())
          .thenAnswer((_) async => ConnectivityResult.wifi);

      final service = ConnectivityService(connectivity: mockConnectivity);
      await service.initialize();

      expectLater(
        service.onConnectivityChanged,
        emits(false),
      );

      streamController.add(ConnectivityResult.none);
      await Future.delayed(Duration.zero);

      expect(service.isOnline, isFalse);
      await service.dispose();
    });

    test('emits true when connectivity is restored', () async {
      when(() => mockConnectivity.checkConnectivity())
          .thenAnswer((_) async => ConnectivityResult.none);

      final service = ConnectivityService(connectivity: mockConnectivity);
      await service.initialize();

      expect(service.isOnline, isFalse);

      expectLater(
        service.onConnectivityChanged,
        emits(true),
      );

      streamController.add(ConnectivityResult.mobile);
      await Future.delayed(Duration.zero);

      expect(service.isOnline, isTrue);
      await service.dispose();
    });

    test('does not emit duplicate values', () async {
      when(() => mockConnectivity.checkConnectivity())
          .thenAnswer((_) async => ConnectivityResult.wifi);

      final service = ConnectivityService(connectivity: mockConnectivity);
      await service.initialize();

      final emissions = <bool>[];
      service.onConnectivityChanged.listen(emissions.add);

      streamController.add(ConnectivityResult.wifi);
      await Future.delayed(Duration.zero);

      streamController.add(ConnectivityResult.none);
      await Future.delayed(Duration.zero);

      expect(emissions, [false]);
      await service.dispose();
    });
  });
}
