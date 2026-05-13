import 'package:dio/dio.dart';

class ScannerApi {
  // Local emulator backend
  final Dio dio = Dio(
    BaseOptions(
      baseUrl: 'http://10.0.2.2:8080/api', 
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
    ),
  );

  /// Phase 7: Fast API EasyOCR Engine (Hugging Face Spaces)
  Future<Map<String, dynamic>> extractText(String base64Image) async {
    try {
      // Hit the Hugging Face Python OCR Microservice!
      final ocrDio = Dio(BaseOptions(
        baseUrl: 'https://arghyadevdas-food-scanner-ocr.hf.space', 
        connectTimeout: const Duration(seconds: 60),
        receiveTimeout: const Duration(seconds: 60),
      ));

      final response = await ocrDio.post('/ocr/extract', data: {"image": base64Image});
      return response.data as Map<String, dynamic>;
    } catch (e) {
      rethrow;
    }
  }

  /// Phase 8: Spring Boot GLM API
  Future<Map<String, dynamic>> analyzeIngredients(List<String> ingredients, String rawText) async {
    try {
      // Hit the local Spring Boot Backend!
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
