import 'package:localai_frontend/domain/entities/location.dart';
import 'package:localai_frontend/domain/entities/user.dart';
import 'package:localai_frontend/domain/entities/review.dart';

class TestFixtures {
  static const testUser = User(
    id: '1',
    username: 'testuser',
    email: 'test@example.com',
  );

  static const testLocation = Location(
    id: '1',
    title: 'Discovery Place',
    category: 'Nature',
    score: 0.95,
    imageUrl: null,
    isBookmarked: false,
  );

  static final testReview = Review(
    id: '1',
    locationId: '1',
    userId: '1',
    rating: 5,
    comment: 'Amazing experience!',
    createdAt: DateTime.now(),
    user: testUser,
  );

  static List<Map<String, dynamic>> get mockLocationsJson => [
    {
      'id': '1',
      'title': 'Discovery Place',
      'category': 'Nature',
      'score': 0.95,
      'imageUrl': null,
    },
    {
      'id': '2',
      'title': 'The Innovation Hub',
      'category': 'Technology',
      'score': 0.88,
      'imageUrl': null,
    }
  ];

  static Map<String, dynamic> get mockLoginResponse => {
    'success': true,
    'data': {
      'accessToken': 'mock_access_token',
      'refreshToken': 'mock_refresh_token',
      'user': {
        'id': 1,
        'username': 'testuser',
        'email': 'test@example.com',
      }
    }
  };

  static Map<String, dynamic> get mockRegisterResponse => {
    'success': true,
    'data': {
      'accessToken': 'mock_access_token',
      'refreshToken': 'mock_refresh_token',
      'user': {
        'id': 1,
        'username': 'testuser',
        'email': 'test@example.com',
      }
    }
  };
}
