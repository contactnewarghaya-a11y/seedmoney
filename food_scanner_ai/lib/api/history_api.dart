import 'package:dio/dio.dart';
import '../models/scan_history.dart';
import '../models/analysis_result.dart';

class HistoryApi {
  // Live Cloud Backend on Render.com
  final Dio dio = Dio(
    BaseOptions(
      baseUrl: 'https://seedmoney-7z7x.onrender.com/api', 
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
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
