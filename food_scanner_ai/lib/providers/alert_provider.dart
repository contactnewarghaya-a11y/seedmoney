import 'package:flutter/foundation.dart';
import '../api/alert_api.dart';

class AlertProvider with ChangeNotifier {
  final AlertApi _api = AlertApi();
  List<Map<String, dynamic>> _alerts = [];
  bool _isLoading = true;

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
    
    _alerts = await _api.getAlerts();
    
    _isLoading = false;
    notifyListeners();
  }

  Future<void> markAllAsRead() async {
    await _api.markAllAsRead();
    for (var a in _alerts) {
      a['read'] = true;
    }
    notifyListeners();
  }
}
