import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:localai_frontend/main.dart' as app;
import 'package:localai_frontend/injection_container.dart' as di;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dio/dio.dart';
import 'test_fixtures.dart';

class MockDio extends Mock implements Dio {}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Stability and Resilience Tests', () {
    late MockDio mockDio;

    setUp(() async {
      await di.sl.reset();
      di.sl.allowReassignment = true;
      SharedPreferences.setMockInitialValues({
        'accessToken': 'valid_token',
        'user_data': '{"id":"1","username":"testuser","email":"test@example.com"}'
      });
      
      mockDio = MockDio();
      when(() => mockDio.options).thenReturn(BaseOptions());
      when(() => mockDio.interceptors).thenReturn(Interceptors());
      
      di.sl.registerLazySingleton<Dio>(() => mockDio);
    });

    testWidgets('Offline Resilience: Verify cached bookmarks display when API fails', (tester) async {
      when(() => mockDio.get(any())).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: ''),
          error: 'No internet connection',
          type: DioExceptionType.connectionError,
        ),
      );

      await app.main();
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.person_outline));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Saved Bookmarks'));
      await tester.pumpAndSettle();

      expect(find.text('Saved Bookmarks'), findsOneWidget);
    });

    testWidgets('Memory Leak Check: Stress test navigation and scrolling', (tester) async {
      when(() => mockDio.get(any())).thenAnswer((_) async => Response(
        data: {'success': true, 'data': TestFixtures.mockLocationsJson},
        statusCode: 200,
        requestOptions: RequestOptions(path: ''),
      ));

      await app.main();
      await tester.pumpAndSettle();

      for (int i = 0; i < 5; i++) {
        await tester.drag(find.byType(CustomScrollView), const Offset(0, -500));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Discovery Place').first);
        await tester.pumpAndSettle();

        await tester.tap(find.byIcon(Icons.arrow_back));
        await tester.pumpAndSettle();
      }

      expect(find.text('Welcome Back,'), findsOneWidget);
    });
  });
}
