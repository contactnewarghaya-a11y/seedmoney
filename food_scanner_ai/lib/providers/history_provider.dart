import 'package:flutter/foundation.dart';
import '../models/scan_history.dart';
import '../models/analysis_result.dart';
import '../api/history_api.dart';

class HistoryProvider with ChangeNotifier {
  final HistoryApi _api = HistoryApi();
  List<ScanHistoryItem> _history = [];

  HistoryProvider() {
    fetchHistory();
  }

  Future<void> fetchHistory() async {
    _history = await _api.getHistory();
    notifyListeners();
  }


  List<ScanHistoryItem> get history => _history;

  void deleteItem(String id) {
    _history.removeWhere((item) => item.id == id);
    notifyListeners();
  }

  void clearHistory() {
    _history.clear();
    notifyListeners();
  }

  void toggleFavorite(String id) {
    final index = _history.indexWhere((item) => item.id == id);
    if (index != -1) {
      _history[index] = _history[index].copyWith(
        isFavorite: !_history[index].isFavorite,
      );
      notifyListeners();
    }
  }

  // To be used when a new scan is completed
  void addScan(AnalysisResult result) {
    _history.insert(
      0,
      ScanHistoryItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        createdAt: DateTime.now(),
        result: result,
      ),
    );
    notifyListeners();
  }
}
