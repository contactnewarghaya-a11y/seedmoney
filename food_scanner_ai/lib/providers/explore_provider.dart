import 'package:flutter/foundation.dart';
import '../api/explore_api.dart';

class ExploreProvider with ChangeNotifier {
  final ExploreApi _api = ExploreApi();
  List<Map<String, dynamic>> _results = [];
  bool _isLoading = false;

  List<Map<String, dynamic>> get results => _results;
  bool get isLoading => _isLoading;

  Future<void> search(String query) async {
    _isLoading = true;
    notifyListeners();
    
    _results = await _api.searchIngredients(query);
    
    _isLoading = false;
    notifyListeners();
  }
}
