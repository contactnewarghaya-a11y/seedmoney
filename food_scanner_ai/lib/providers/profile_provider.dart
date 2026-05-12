import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_profile.dart';
import '../api/profile_api.dart';

class ProfileProvider with ChangeNotifier {
  final ProfileApi _api = ProfileApi();
  UserProfile _profile = UserProfile.empty();
  bool _isLoading = true;

  UserProfile get profile => _profile;
  bool get isLoading => _isLoading;

  ProfileProvider() {
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Try to load from API first
    final apiProfile = await _api.getProfile();
    if (apiProfile != null) {
      _profile = apiProfile;
    } else {
      // Fallback to local storage
      final allergens = prefs.getStringList('profile_allergens') ?? [];
      final conditions = prefs.getStringList('profile_conditions') ?? [];
      final dietary = prefs.getStringList('profile_dietary') ?? [];

      _profile = UserProfile(
        allergens: allergens,
        conditions: conditions,
        dietaryPreferences: dietary,
      );
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> saveProfile(UserProfile newProfile) async {
    _profile = newProfile;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('profile_allergens', newProfile.allergens);
    await prefs.setStringList('profile_conditions', newProfile.conditions);
    await prefs.setStringList('profile_dietary', newProfile.dietaryPreferences);

    // Sync to backend
    await _api.updateProfile(newProfile);
  }

  Future<void> toggleAllergen(String allergen, bool isSelected) async {
    final List<String> current = List.from(_profile.allergens);
    if (isSelected) {
      if (!current.contains(allergen)) current.add(allergen);
    } else {
      current.remove(allergen);
    }
    await saveProfile(_profile.copyWith(allergens: current));
  }

  Future<void> toggleCondition(String condition, bool isSelected) async {
    final List<String> current = List.from(_profile.conditions);
    if (isSelected) {
      if (!current.contains(condition)) current.add(condition);
    } else {
      current.remove(condition);
    }
    await saveProfile(_profile.copyWith(conditions: current));
  }

  Future<void> toggleDietary(String pref, bool isSelected) async {
    final List<String> current = List.from(_profile.dietaryPreferences);
    if (isSelected) {
      if (!current.contains(pref)) current.add(pref);
    } else {
      current.remove(pref);
    }
    await saveProfile(_profile.copyWith(dietaryPreferences: current));
  }
}
