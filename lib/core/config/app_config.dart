class AppConfig {
  static const String baseUrl = 'http://localhost:3000/api/v1';
  static const int connectTimeout = 5000;
  static const int receiveTimeout = 3000;
  
  // API Endpoints
  static const String loginEndpoint = '/auth/login';
  static const String registerEndpoint = '/auth/register';
  static const String recommendationsEndpoint = '/recommendations/generate';
}
