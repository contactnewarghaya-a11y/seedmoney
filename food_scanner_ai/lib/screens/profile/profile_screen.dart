import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/profile_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  final List<String> _commonAllergens = const [
    'Peanut', 'Tree Nuts', 'Milk', 'Eggs', 'Wheat', 'Soy', 'Fish', 'Shellfish'
  ];

  final List<String> _commonConditions = const [
    'Diabetes', 'Hypertension', 'Lactose Intolerance', 'Celiac Disease'
  ];

  final List<String> _dietaryPrefs = const [
    'Vegan', 'Vegetarian', 'Keto', 'Paleo'
  ];

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProfileProvider>();
    final profile = provider.profile;

    if (provider.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Health Profile'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/dashboard'),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionHeader(context, 'Food Allergies'),
              ..._commonAllergens.map((allergen) {
                return SwitchListTile(
                  title: Text(allergen),
                  value: profile.allergens.contains(allergen),
                  onChanged: (val) => provider.toggleAllergen(allergen, val),
                  activeThumbColor: Colors.red.shade400,
                );
              }),
              const Divider(),

              _buildSectionHeader(context, 'Health Conditions'),
              ..._commonConditions.map((condition) {
                return SwitchListTile(
                  title: Text(condition),
                  value: profile.conditions.contains(condition),
                  onChanged: (val) => provider.toggleCondition(condition, val),
                  activeThumbColor: Colors.orange.shade400,
                );
              }),
              const Divider(),

              _buildSectionHeader(context, 'Dietary Preferences'),
              ..._dietaryPrefs.map((pref) {
                return SwitchListTile(
                  title: Text(pref),
                  value: profile.dietaryPreferences.contains(pref),
                  onChanged: (val) => provider.toggleDietary(pref, val),
                  activeThumbColor: Colors.green.shade400,
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
      ),
    );
  }
}
