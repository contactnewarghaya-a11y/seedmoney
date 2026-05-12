import 'package:dio/dio.dart';

class ScannerApi {
  // Use actual IP for physical device testing
  final Dio dio = Dio(
    BaseOptions(
      baseUrl: 'http://10.0.2.18:8080/api', 
      connectTimeout: const Duration(seconds: 5),
      receiveTimeout: const Duration(seconds: 5),
    ),
  );

  /// Phase 7: Fast API EasyOCR Engine
  Future<Map<String, dynamic>> extractText(String base64Image) async {
    try {
      // Hit the Python FastAPI Microservice!
      final ocrDio = Dio(BaseOptions(
        baseUrl: 'http://10.0.2.18:8000', 
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
      ));

      final response = await ocrDio.post('/ocr/extract', data: {"image": base64Image});
      return response.data as Map<String, dynamic>;
    } catch (e) {
      rethrow;
    }
  }

  /// Phase 8: Spring Boot GLM API Mock
  Future<Map<String, dynamic>> analyzeIngredients(List<String> ingredients, String rawText) async {
    try {
      // Hit the Spring Boot Backend!
      final response = await dio.post('/analyze', data: {
        "ingredients": ingredients,
        "rawText": rawText,
      });
      return response.data as Map<String, dynamic>;
    } catch (e) {
      rethrow;
    }
  }
}
