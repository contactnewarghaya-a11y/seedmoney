import 'package:dio/dio.dart';
import '../models/scan_history.dart';
import '../models/analysis_result.dart';

class HistoryApi {
  // Local emulator backend
  final Dio dio = Dio(
    BaseOptions(
      baseUrl: 'http://10.0.2.2:8080/api', 
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
          rawImageBase64: '', // Images are not stored in DB
          ingredients: List<String>.from(json['ingredients'] ?? []),
        );

        // createdAt may be a List [year, month, day, h, m, s, ns] from Java LocalDateTime
        DateTime createdAt;
        try {
          final raw = json['createdAt'];
          if (raw is String) {
            createdAt = DateTime.parse(raw);
          } else if (raw is List) {
            createdAt = DateTime(raw[0], raw[1], raw[2],
              raw.length > 3 ? raw[3] : 0,
              raw.length > 4 ? raw[4] : 0,
              raw.length > 5 ? raw[5] : 0);
          } else {
            createdAt = DateTime.now();
          }
        } catch (_) {
          createdAt = DateTime.now();
        }

        return ScanHistoryItem(
          id: json['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
          createdAt: createdAt,
          result: result,
          isFavorite: json['isFavorite'] ?? false,
        );
      }).toList();
    } catch (e) {
      // Return empty list if backend is offline
      return []; 
    }
  }
}
