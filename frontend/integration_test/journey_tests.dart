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

  group('Professional E2E Journey Tests', () {
    late MockDio mockDio;

    setUpAll(() {
      registerFallbackValue(RequestOptions(path: ''));
    });

    setUp(() async {
      await di.sl.reset();
      di.sl.allowReassignment = true;
      
      SharedPreferences.setMockInitialValues({});
      mockDio = MockDio();

      when(() => mockDio.options).thenReturn(BaseOptions());
      when(() => mockDio.interceptors).thenReturn(Interceptors());

      // Mock Registration
      when(() => mockDio.post(
            any(that: contains('register')),
            data: any(named: 'data'),
          )).thenAnswer((_) async => Response(
            data: TestFixtures.mockRegisterResponse,
            statusCode: 201,
            requestOptions: RequestOptions(path: ''),
          ));

      // Mock Login
      when(() => mockDio.post(
            any(that: contains('login')),
            data: any(named: 'data'),
          )).thenAnswer((_) async => Response(
            data: TestFixtures.mockLoginResponse,
            statusCode: 200,
            requestOptions: RequestOptions(path: ''),
          ));

      // Mock Preference Sync
      when(() => mockDio.put(
            any(that: contains('preferences')),
            data: any(named: 'data'),
          )).thenAnswer((_) async => Response(
            data: {'success': true},
            statusCode: 200,
            requestOptions: RequestOptions(path: ''),
          ));

      // Mock Seed Generation
      when(() => mockDio.post(
            any(that: contains('generate')),
            data: any(named: 'data'),
          )).thenAnswer((_) async => Response(
            data: {'success': true},
            statusCode: 201,
            requestOptions: RequestOptions(path: ''),
          ));

      // Mock Recommendations Fetch
      when(() => mockDio.get(
            any(that: contains('recommendations')),
          )).thenAnswer((_) async => Response(
            data: {
              'success': true,
              'data': TestFixtures.mockLocationsJson,
            },
            statusCode: 200,
            requestOptions: RequestOptions(path: ''),
          ));

      // Mock Review Submission
      when(() => mockDio.post(
            any(that: contains('reviews')),
            data: any(named: 'data'),
          )).thenAnswer((_) async => Response(
            data: {'success': true, 'message': 'Review submitted'},
            statusCode: 201,
            requestOptions: RequestOptions(path: ''),
          ));

      // Mock Review Fetch
      when(() => mockDio.get(
            any(that: contains('reviews')),
          )).thenAnswer((_) async => Response(
            data: {
              'success': true,
              'reviews': [],
              'stats': {'averageRating': 4.5, 'reviewCount': 10}
            },
            statusCode: 200,
            requestOptions: RequestOptions(path: ''),
          ));
    });

    testWidgets('1. Onboarding Journey: Register -> Preferences -> Main Hub', (tester) async {
      await app.main();
      await tester.pumpAndSettle();

      // Navigate to Register
      await tester.tap(find.text('Register'));
      await tester.pumpAndSettle();

      // Fill registration form
      await tester.enterText(find.byType(TextFormField).at(0), 'testuser');
      await tester.enterText(find.byType(TextFormField).at(1), 'test@example.com');
      await tester.enterText(find.byType(TextFormField).at(2), 'Password123!');
      await tester.enterText(find.byType(TextFormField).at(3), 'Password123!');
      
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle(const Duration(seconds: 1));

      // Assert Preferences Page
      expect(find.text('What are you\ninterested in?'), findsOneWidget);
      
      // Select interests
      await tester.tap(find.text('Fitness'));
      await tester.tap(find.text('Food'));
      await tester.tap(find.text('Nature'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Get Started'));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Arrival at Main Hub
      expect(find.text('Welcome Back,'), findsOneWidget);
      expect(find.text('testuser'), findsOneWidget);
      expect(find.text('Discovery Place'), findsOneWidget);
    });

    testWidgets('2. Discovery Journey: Search -> Details -> Review', (tester) async {
      // Mock authenticated state
      SharedPreferences.setMockInitialValues({
        'accessToken': 'mock_token',
        'user_data': '{"id":"1","username":"testuser","email":"test@example.com"}'
      });
      
      await app.main();
      await tester.pumpAndSettle();

      // Open Search
      await tester.tap(find.text('Where do you want to go today?'));
      await tester.pumpAndSettle();

      // Enter search query
      await tester.enterText(find.byType(TextField), 'quiet park');
      await tester.testTextInput.receiveAction(TextInputAction.search);
      await tester.pumpAndSettle();

      // Tap on a search result (The Innovation Hub from TestFixtures)
      await tester.tap(find.text('The Innovation Hub').first);
      await tester.pumpAndSettle();

      // Verify Details Page
      expect(find.text('Match Score'), findsOneWidget);
      expect(find.text('Directions'), findsOneWidget);

      // Open Review Modal
      await tester.tap(find.text('Review'));
      await tester.pumpAndSettle();

      // Submit Review
      await tester.enterText(find.byType(TextField).last, 'Excellent spot for deep work!');
      await tester.tap(find.text('Submit'));
      await tester.pumpAndSettle();

      expect(find.text('Review submitted successfully!'), findsOneWidget);
    });

    testWidgets('3. Retention Journey: Bookmark -> Verify in Bookmarks Page', (tester) async {
      SharedPreferences.setMockInitialValues({
        'accessToken': 'mock_token',
        'user_data': '{"id":"1","username":"testuser","email":"test@example.com"}'
      });

      await app.main();
      await tester.pumpAndSettle();

      // Tap Bookmark icon on a card
      final bookmarkIcon = find.byIcon(Icons.bookmark_border).first;
      await tester.tap(bookmarkIcon);
      await tester.pumpAndSettle();

      // Navigate to Profile
      await tester.tap(find.byIcon(Icons.person_outline));
      await tester.pumpAndSettle();

      // Go to Bookmarks Page
      await tester.tap(find.text('Saved Bookmarks'));
      await tester.pumpAndSettle();

      // Verify item exists in the list
      expect(find.text('Discovery Place'), findsOneWidget);
      expect(find.text('Saved Bookmarks'), findsOneWidget);
    });

    testWidgets('4. Auth Security: Access Control Verification', (tester) async {
      // Ensure completely fresh state (unauthenticated)
      SharedPreferences.setMockInitialValues({});
      
      await app.main();
      await tester.pumpAndSettle();

      // App should start at Login
      expect(find.text('Login'), findsOneWidget);
      expect(find.text('Create Account'), findsNothing); // Not on register page

      // Note: Full redirect testing usually requires manipulating the router state 
      // directly or mocking the AuthBloc state. In this E2E context, we confirm 
      // the Unauthenticated state correctly presents the Login screen.
    });
  });
}
