import 'package:dio/dio.dart';

class AuthApi {
  final Dio dio = Dio(
    BaseOptions(
      // Using a placeholder base URL for now. In a real app this would point to the Spring Boot backend
      baseUrl: 'https://api.example.com',
      connectTimeout: const Duration(seconds: 5),
      receiveTimeout: const Duration(seconds: 3),
    ),
  );

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      // Mocked response for development/testing
      await Future.delayed(const Duration(seconds: 1)); // Simulate network latency
      if (email == 'test@test.com' && password == 'password') {
        return {
          'success': true,
          'token': 'mock_jwt_token_for_development',
          'user': {
            'id': '1',
            'email': email,
            'name': 'Test User'
          }
        };
      } else {
        throw Exception('Invalid credentials');
      }

      /* Real implementation:
      final response = await dio.post(
        '/auth/login',
        data: {
          "email": email,
          "password": password
        },
      );
      return response.data;
      */
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> register(String name, String email, String password) async {
    try {
      // Mocked response for development
      await Future.delayed(const Duration(seconds: 1));
      return {
        'success': true,
        'token': 'mock_jwt_token_for_development',
      };
      
      /* Real implementation
      final response = await dio.post(
        '/auth/register',
        data: {
          "name": name,
          "email": email,
          "password": password
        },
      );
      return response.data;
      */
    } catch (e) {
      rethrow;
    }
  }
}
