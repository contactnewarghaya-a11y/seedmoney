import 'package:dio/dio.dart';
import '../models/scan_history.dart';
import '../models/analysis_result.dart';

class HistoryApi {
  // Use actual IP for physical device testing
  final Dio dio = Dio(
    BaseOptions(
      baseUrl: 'http://10.0.2.18:8080/api', 
      connectTimeout: const Duration(seconds: 5),
      receiveTimeout: const Duration(seconds: 5),
    ),
  );

  Future<List<ScanHistoryItem>> getHistory() async {
    try {
      final response = await dio.get('/analyze/history');
      final data = response.data as List;
      
      return data.map((json) {
        // Build AnalysisResult from the flattened DB response
        final result = AnalysisResult(
          dangerous: List<String>.from(json['dangerous'] ?? []),
          nutritionScore: json['nutritionScore'] ?? 0,
          riskLevel: json['riskLevel'] ?? 'Unknown',
          warning: json['warning'] ?? '',
          rawImageBase64: '', // We don't store images in DB yet
          ingredients: List<String>.from(json['ingredients'] ?? []),
        );

        return ScanHistoryItem(
          id: json['id'],
          createdAt: DateTime.parse(json['createdAt']),
          result: result,
          isFavorite: json['isFavorite'] ?? false,
        );
      }).toList();
    } catch (e) {
      // Return empty list if backend is offline to prevent crash
      return []; 
    }
  }
}
