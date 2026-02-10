import 'dart:io';

class AppConfig {
  static String get baseUrl {
    if (Platform.isAndroid) {
      return 'http://10.0.2.2:3000/api/v1';
    } else {
      return 'http://localhost:3000/api/v1';
    }
  }
  static const int connectTimeout = 5000;
  static const int receiveTimeout = 3000;
  
  // API Endpoints
  static const String loginEndpoint = '/auth/login';
  static const String registerEndpoint = '/auth/register';
  static const String recommendationsEndpoint = '/recommendations/generate';
}

