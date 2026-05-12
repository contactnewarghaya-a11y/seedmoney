import 'package:dio/dio.dart';
import '../models/user_profile.dart';

class ProfileApi {
  // Live Cloud Backend on Render.com
  final Dio dio = Dio(
    BaseOptions(
      baseUrl: 'https://seedmoney-7z7x.onrender.com/api', 
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
    ),
  );

  Future<UserProfile?> getProfile() async {
    try {
      final response = await dio.get('/profile');
      final data = response.data;
      return UserProfile(
        allergens: List<String>.from(data['allergens'] ?? []),
        conditions: List<String>.from(data['conditions'] ?? []),
        dietaryPreferences: List<String>.from(data['dietaryPreferences'] ?? []),
        rewardPoints: data['rewardPoints'] ?? 0,
        totalScans: data['totalScans'] ?? 0,
      );
    } catch (e) {
      return null;
    }
  }

  Future<void> updateProfile(UserProfile profile) async {
    try {
      await dio.post('/profile', data: {
        "allergens": profile.allergens,
        "conditions": profile.conditions,
        "dietaryPreferences": profile.dietaryPreferences
      });
    } catch (e) {
      // Ignore if offline
    }
  }
}
