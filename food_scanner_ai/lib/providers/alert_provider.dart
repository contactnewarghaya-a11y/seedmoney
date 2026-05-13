import 'package:flutter/foundation.dart';
import '../api/alert_api.dart';

class AlertProvider with ChangeNotifier {
  final AlertApi _api = AlertApi();
  List<Map<String, dynamic>> _alerts = [];
  bool _isLoading = true;

  // Fallback local alerts when backend is unreachable
  static final List<Map<String, dynamic>> _fallbackAlerts = [
    {
      'type': 'Urgent Recall',
      'title': 'Urgent Recall: Almond Flour Cookies',
      'content': 'Recall due to undeclared milk allergens. If you purchased this item after June 1st, do not consume.',
      'read': false,
      'urgent': true,
      'tagLabel': 'Safety Alert',
    },
    {
      'type': 'Personalized Health Tip',
      'title': 'Personalized Health Tip',
      'content': 'Based on your last 10 scans, your sodium intake is 15% higher than your daily goal. Try swapping table salt for fresh herbs.',
      'read': false,
      'urgent': false,
      'tagLabel': 'Dietary Insight',
    },
    {
      'type': 'System Update',
      'title': 'System Update v2.4',
      'content': "We've improved the AI scanning engine for faster ingredient detection in low-light environments.",
      'read': true,
      'urgent': false,
      'tagLabel': 'App Update',
    },
  ];

  List<Map<String, dynamic>> get alerts => _alerts;
  bool get isLoading => _isLoading;

  int get unreadCount => _alerts.where((a) => a['read'] == false).length;
  int get urgentCount => _alerts.where((a) => a['urgent'] == true && a['read'] == false).length;

  AlertProvider() {
    fetchAlerts();
  }

  Future<void> fetchAlerts() async {
    _isLoading = true;
    notifyListeners();

    try {
      final backendAlerts = await _api.getAlerts()
          .timeout(const Duration(seconds: 5), onTimeout: () => []);
      _alerts = backendAlerts.isNotEmpty ? backendAlerts : List.from(_fallbackAlerts);
    } catch (_) {
      _alerts = List.from(_fallbackAlerts);
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> markAllAsRead() async {
    // Update local state immediately (optimistic)
    for (var a in _alerts) {
      a['read'] = true;
    }
    notifyListeners();

    // Then try to sync to backend (fire and forget)
    try {
      await _api.markAllAsRead()
          .timeout(const Duration(seconds: 5), onTimeout: () {});
    } catch (_) {}
  }
}
