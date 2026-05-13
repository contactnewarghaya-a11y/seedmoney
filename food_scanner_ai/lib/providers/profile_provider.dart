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
      // Also cache to local storage
      await _cacheLocally(prefs, apiProfile);
    } else {
      // Fallback to local storage
      _profile = UserProfile(
        fullName: prefs.getString('profile_fullName') ?? 'Arjun Sharma',
        email: prefs.getString('profile_email') ?? 'arjun.sharma@example.com',
        avatarUrl: prefs.getString('profile_avatarUrl'),
        isPro: prefs.getBool('profile_isPro') ?? true,
        joinDate: prefs.getString('profile_joinDate') ?? 'May 2023',
        allergens: prefs.getStringList('profile_allergens') ?? [],
        conditions: prefs.getStringList('profile_conditions') ?? [],
        dietaryPreferences: prefs.getStringList('profile_dietary') ?? [],
      );
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> _cacheLocally(SharedPreferences prefs, UserProfile p) async {
    await prefs.setString('profile_fullName', p.fullName);
    await prefs.setString('profile_email', p.email);
    if (p.avatarUrl != null) await prefs.setString('profile_avatarUrl', p.avatarUrl!);
    await prefs.setBool('profile_isPro', p.isPro);
    await prefs.setString('profile_joinDate', p.joinDate);
    await prefs.setStringList('profile_allergens', p.allergens);
    await prefs.setStringList('profile_conditions', p.conditions);
    await prefs.setStringList('profile_dietary', p.dietaryPreferences);
  }

  Future<void> saveProfile(UserProfile newProfile) async {
    _profile = newProfile;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await _cacheLocally(prefs, newProfile);

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
