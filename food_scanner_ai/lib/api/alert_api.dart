import 'package:dio/dio.dart';

class AlertApi {
  final Dio dio = Dio(
    BaseOptions(
      baseUrl: 'http://10.0.2.2:8080/api', 
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
    ),
  );

  Future<List<Map<String, dynamic>>> getAlerts() async {
    try {
      final response = await dio.get('/alerts');
      return List<Map<String, dynamic>>.from(response.data);
    } catch (e) {
      return [];
    }
  }

  Future<void> markAllAsRead() async {
    try {
      await dio.post('/alerts/mark-read');
    } catch (e) {
      // Ignore if offline
    }
  }
}
