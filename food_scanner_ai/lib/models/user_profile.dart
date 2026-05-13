class UserProfile {
  final String fullName;
  final String email;
  final String? avatarUrl;
  final bool isPro;
  final String joinDate;
  final List<String> allergens;
  final List<String> conditions;
  final List<String> dietaryPreferences;
  final int rewardPoints;
  final int totalScans;

  UserProfile({
    this.fullName = 'Arjun Sharma',
    this.email = 'arjun.sharma@example.com',
    this.avatarUrl,
    this.isPro = true,
    this.joinDate = 'May 2023',
    required this.allergens,
    required this.conditions,
    required this.dietaryPreferences,
    this.rewardPoints = 0,
    this.totalScans = 0,
  });

  factory UserProfile.empty() {
    return UserProfile(
      allergens: [], 
      conditions: [], 
      dietaryPreferences: [],
      rewardPoints: 0,
      totalScans: 0,
    );
  }

  UserProfile copyWith({
    String? fullName,
    String? email,
    String? avatarUrl,
    bool? isPro,
    String? joinDate,
    List<String>? allergens,
    List<String>? conditions,
    List<String>? dietaryPreferences,
    int? rewardPoints,
    int? totalScans,
  }) {
    return UserProfile(
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      isPro: isPro ?? this.isPro,
      joinDate: joinDate ?? this.joinDate,
      allergens: allergens ?? this.allergens,
      conditions: conditions ?? this.conditions,
      dietaryPreferences: dietaryPreferences ?? this.dietaryPreferences,
      rewardPoints: rewardPoints ?? this.rewardPoints,
      totalScans: totalScans ?? this.totalScans,
    );
  }
}
