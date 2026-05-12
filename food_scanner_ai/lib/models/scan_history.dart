import '../models/analysis_result.dart';

class ScanHistoryItem {
  final String id;
  final DateTime createdAt;
  final AnalysisResult result;
  final bool isFavorite;

  ScanHistoryItem({
    required this.id,
    required this.createdAt,
    required this.result,
    this.isFavorite = false,
  });

  ScanHistoryItem copyWith({
    bool? isFavorite,
  }) {
    return ScanHistoryItem(
      id: id,
      createdAt: createdAt,
      result: result,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }
}
