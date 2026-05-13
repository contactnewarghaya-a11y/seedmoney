import 'package:dio/dio.dart';
import '../models/user_profile.dart';

class ProfileApi {
  // Local emulator backend
  final Dio dio = Dio(
    BaseOptions(
      baseUrl: 'http://10.0.2.2:8080/api', 
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
    ),
  );

  Future<UserProfile?> getProfile() async {
    try {
      final response = await dio.get('/profile');
      final data = response.data;
      return UserProfile(
        fullName: data['fullName'] ?? 'Arjun Sharma',
        email: data['email'] ?? 'arjun.sharma@example.com',
        avatarUrl: data['avatarUrl'],
        isPro: data['pro'] ?? false,
        joinDate: data['joinDate'] ?? 'May 2023',
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
        "fullName": profile.fullName,
        "email": profile.email,
        "avatarUrl": profile.avatarUrl,
        "pro": profile.isPro,
        "joinDate": profile.joinDate,
        "allergens": profile.allergens,
        "conditions": profile.conditions,
        "dietaryPreferences": profile.dietaryPreferences
      });
    } catch (e) {
      // Ignore if offline
    }
  }
}
