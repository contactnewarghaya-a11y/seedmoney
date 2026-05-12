class UserProfile {
  final List<String> allergens;
  final List<String> conditions;
  final List<String> dietaryPreferences;
  final int rewardPoints;
  final int totalScans;

  UserProfile({
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
    List<String>? allergens,
    List<String>? conditions,
    List<String>? dietaryPreferences,
    int? rewardPoints,
    int? totalScans,
  }) {
    return UserProfile(
      allergens: allergens ?? this.allergens,
      conditions: conditions ?? this.conditions,
      dietaryPreferences: dietaryPreferences ?? this.dietaryPreferences,
      rewardPoints: rewardPoints ?? this.rewardPoints,
      totalScans: totalScans ?? this.totalScans,
    );
  }
}
