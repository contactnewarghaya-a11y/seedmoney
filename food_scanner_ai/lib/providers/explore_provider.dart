import 'package:flutter/foundation.dart';
import '../api/explore_api.dart';

class ExploreProvider with ChangeNotifier {
  final ExploreApi _api = ExploreApi();
  List<Map<String, dynamic>> _results = [];
  bool _isLoading = false;

  // Built-in fallback data — always available even offline
  static const List<Map<String, dynamic>> _fallbackData = [
    {
      'type': 'E-NUMBER',
      'title': 'E102 (Tartrazine)',
      'description': 'A synthetic lemon yellow azo dye used as a food coloring. Primarily found in soft drinks and processed snacks.',
      'status': 'Caution',
      'caution': true,
      'safe': false,
      'allergens': ['Sulfites', 'Salicylates'],
    },
    {
      'type': 'NATURAL',
      'title': 'E100 (Curcumin)',
      'description': 'A natural bright yellow dye produced by turmeric. Recognized for anti-inflammatory properties and used in curries.',
      'status': 'Safe',
      'caution': false,
      'safe': true,
      'allergens': ['None Reported'],
    },
    {
      'type': 'PRESERVATIVE',
      'title': 'Potassium Sorbate',
      'description': 'The potassium salt of sorbic acid. Effective for controlling mold and yeast in cheese, wine, and yogurt.',
      'status': 'Moderate',
      'caution': false,
      'safe': false,
      'allergens': ['Skin Irritation'],
    },
    {
      'type': 'E-NUMBER',
      'title': 'E621 (Monosodium Glutamate)',
      'description': 'A common flavour enhancer added to many savoury dishes, canned vegetables, soups and processed meats.',
      'status': 'Moderate',
      'caution': false,
      'safe': false,
      'allergens': ['Headache (sensitive individuals)'],
    },
    {
      'type': 'PRESERVATIVE',
      'title': 'Sodium Benzoate',
      'description': 'A widely used preservative in acidic foods like salad dressings, carbonated drinks, and fruit juices.',
      'status': 'Caution',
      'caution': true,
      'safe': false,
      'allergens': ['Asthma triggers'],
    },
  ];

  List<Map<String, dynamic>> get results => _results;
  bool get isLoading => _isLoading;

  Future<void> search(String query) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Try backend with a short 5s timeout so we don't freeze the UI
      final backendResults = await _api.searchIngredients(query)
          .timeout(const Duration(seconds: 5), onTimeout: () => []);

      if (backendResults.isNotEmpty) {
        _results = backendResults;
      } else {
        // Use local fallback, filtered by query
        _results = _filterFallback(query);
      }
    } catch (_) {
      _results = _filterFallback(query);
    }

    _isLoading = false;
    notifyListeners();
  }

  List<Map<String, dynamic>> _filterFallback(String query) {
    if (query.isEmpty) return List.from(_fallbackData);
    final q = query.toLowerCase();
    return _fallbackData.where((p) =>
      p['title'].toString().toLowerCase().contains(q) ||
      p['description'].toString().toLowerCase().contains(q)
    ).toList();
  }
}
