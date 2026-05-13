import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/profile_provider.dart';
import '../../providers/auth_provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _selectedLanguage = 'English';
  bool _notificationsEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadLocalSettings();
  }

  Future<void> _loadLocalSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedLanguage = prefs.getString('app_language') ?? 'English';
      _notificationsEnabled = prefs.getBool('notifications_enabled') ?? true;
    });
  }

  Future<void> _saveLanguage(String lang) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('app_language', lang);
    setState(() => _selectedLanguage = lang);
  }

  Future<void> _saveNotifications(bool val) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications_enabled', val);
    setState(() => _notificationsEnabled = val);
  }

  void _showAddAllergenDialog(BuildContext context, ProfileProvider prov) {
    final tc = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Allergen'),
        content: TextField(
          controller: tc,
          decoration: const InputDecoration(
            hintText: 'e.g. Peanuts, Gluten',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
          onSubmitted: (_) {
            if (tc.text.trim().isNotEmpty) {
              prov.toggleAllergen(tc.text.trim(), true);
              Navigator.pop(ctx);
            }
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (tc.text.trim().isNotEmpty) {
                prov.toggleAllergen(tc.text.trim(), true);
                Navigator.pop(ctx);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryColor),
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showEditProfileDialog(BuildContext context, ProfileProvider prov) {
    final nameCtrl = TextEditingController(text: prov.profile.fullName);
    final emailCtrl = TextEditingController(text: prov.profile.email);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit Profile'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(labelText: 'Full Name'),
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: emailCtrl,
              decoration: const InputDecoration(labelText: 'Email Address'),
              keyboardType: TextInputType.emailAddress,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameCtrl.text.trim().isNotEmpty && emailCtrl.text.trim().isNotEmpty) {
                prov.saveProfile(prov.profile.copyWith(
                  fullName: nameCtrl.text.trim(),
                  email: emailCtrl.text.trim(),
                ));
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Profile updated!'), backgroundColor: AppTheme.primaryColor),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryColor),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showAddDietaryGoalDialog(BuildContext context, ProfileProvider prov) {
    final tc = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Dietary Goal'),
        content: TextField(
          controller: tc,
          decoration: const InputDecoration(
            hintText: 'e.g. Weight Loss, High Protein',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (tc.text.trim().isNotEmpty) {
                prov.toggleDietary(tc.text.trim(), true);
                Navigator.pop(ctx);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryColor),
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final languages = ['English', 'हिन्दी (Hindi)', 'বাংলা (Bengali)', 'தமிழ் (Tamil)', 'తెలుగు (Telugu)', 'मराठी (Marathi)'];

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      body: SafeArea(
        child: Consumer<ProfileProvider>(
          builder: (context, profileProv, child) {
            final profile = profileProv.profile;
            return CustomScrollView(
              slivers: [
                // App Bar
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 18,
                              backgroundImage: profile.avatarUrl != null
                                  ? NetworkImage(profile.avatarUrl!)
                                  : const NetworkImage('https://i.pravatar.cc/150?img=11'),
                            ),
                            const SizedBox(width: 12),
                            const Text('NutriScan AI', style: TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.w800, fontSize: 22)),
                          ],
                        ),
                        IconButton(
                          icon: const Icon(Icons.notifications_none_rounded, color: AppTheme.textDark),
                          onPressed: () => context.push('/alerts'),
                        ),
                      ],
                    ),
                  ),
                ),

                // Profile Header
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            GestureDetector(
                              onTap: () => _showEditProfileDialog(context, profileProv),
                              child: Stack(
                                children: [
                                  CircleAvatar(
                                    radius: 40,
                                    backgroundImage: profile.avatarUrl != null
                                        ? NetworkImage(profile.avatarUrl!)
                                        : const NetworkImage('https://i.pravatar.cc/150?img=32'),
                                  ),
                                  Positioned(
                                    bottom: 0, right: 0,
                                    child: Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: BoxDecoration(color: AppTheme.primaryColor, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2)),
                                      child: const Icon(Icons.edit, color: Colors.white, size: 14),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(profile.fullName, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppTheme.textDark)),
                                  const SizedBox(height: 4),
                                  Text(profile.email, style: TextStyle(color: AppTheme.textMuted, fontSize: 13)),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      if (profile.isPro)
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                          decoration: BoxDecoration(color: AppTheme.primaryLightest, borderRadius: BorderRadius.circular(12)),
                                          child: const Text('Pro Member', style: TextStyle(color: AppTheme.primaryColor, fontSize: 11, fontWeight: FontWeight.w700)),
                                        ),
                                      if (profile.isPro) const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(12)),
                                        child: Text('Joined ${profile.joinDate}', style: TextStyle(color: Colors.grey.shade700, fontSize: 11, fontWeight: FontWeight.w600)),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () => _showEditProfileDialog(context, profileProv),
                            icon: const Icon(Icons.person_outline, size: 18),
                            label: const Text('Edit Profile'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryColor,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),

                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([

                      // ── My Allergies ──────────────────────────────────────
                      _SectionContainer(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Row(
                                  children: [
                                    Icon(Icons.warning_amber_rounded, color: AppTheme.dangerRed, size: 22),
                                    SizedBox(width: 8),
                                    Text('My Allergies', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppTheme.textDark)),
                                  ],
                                ),
                                TextButton(
                                  onPressed: () => _showAddAllergenDialog(context, profileProv),
                                  style: TextButton.styleFrom(foregroundColor: AppTheme.primaryColor),
                                  child: const Text('+ Add', style: TextStyle(fontWeight: FontWeight.w700)),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            if (profile.allergens.isEmpty)
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                child: Text('No allergies added yet. Tap "+ Add" to begin.', style: TextStyle(color: AppTheme.textMuted, fontSize: 13)),
                              ),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                ...profile.allergens.map((allergen) => _AllergyChip(
                                  label: allergen,
                                  icon: Icons.grass_outlined,
                                  onDelete: () => profileProv.toggleAllergen(allergen, false),
                                )),
                                InkWell(
                                  onTap: () => _showAddAllergenDialog(context, profileProv),
                                  borderRadius: BorderRadius.circular(20),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(color: Colors.grey.shade400),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.add, size: 16, color: Colors.grey.shade600),
                                        const SizedBox(width: 6),
                                        Text('Add New', style: TextStyle(color: Colors.grey.shade600, fontSize: 13, fontWeight: FontWeight.w600)),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'NutriScan will automatically alert you when these ingredients are detected in your scans.',
                              style: TextStyle(color: AppTheme.textMuted, fontSize: 13, height: 1.4),
                            ),
                          ],
                        ),
                      ),

                      // ── Dietary Goals ─────────────────────────────────────
                      _SectionContainer(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Dietary Goals', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppTheme.textDark)),
                                TextButton(
                                  onPressed: () => _showAddDietaryGoalDialog(context, profileProv),
                                  style: TextButton.styleFrom(foregroundColor: AppTheme.primaryColor),
                                  child: const Text('+ Add', style: TextStyle(fontWeight: FontWeight.w700)),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            if (profile.dietaryPreferences.isEmpty)
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                child: Text('No dietary goals set. Tap "+ Add" to begin.', style: TextStyle(color: AppTheme.textMuted, fontSize: 13)),
                              )
                            else ...[
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                decoration: BoxDecoration(
                                  color: AppTheme.primaryLightest,
                                  borderRadius: BorderRadius.circular(12),
                                  border: const Border(left: BorderSide(color: AppTheme.primaryColor, width: 4)),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text('Current Focus', style: TextStyle(color: AppTheme.primaryColor, fontSize: 12)),
                                        const SizedBox(height: 2),
                                        Text(profile.dietaryPreferences.first, style: const TextStyle(color: AppTheme.primaryColor, fontSize: 15, fontWeight: FontWeight.w700)),
                                      ],
                                    ),
                                    const Icon(Icons.trending_up, color: AppTheme.primaryColor),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 12),
                              ...profile.dietaryPreferences.skip(1).map((pref) => Container(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.grey.shade100))),
                                child: Row(
                                  children: [
                                    const Icon(Icons.star_border_outlined, color: AppTheme.textDark, size: 20),
                                    const SizedBox(width: 12),
                                    Text(pref, style: const TextStyle(color: AppTheme.textDark, fontSize: 15, fontWeight: FontWeight.w500)),
                                    const Spacer(),
                                    GestureDetector(
                                      onTap: () => profileProv.toggleDietary(pref, false),
                                      child: const Icon(Icons.close, color: Colors.grey, size: 18),
                                    ),
                                  ],
                                ),
                              )),
                            ],
                          ],
                        ),
                      ),

                      // ── Language ──────────────────────────────────────────
                      _SectionContainer(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                Icon(Icons.language_outlined, color: AppTheme.textDark, size: 20),
                                SizedBox(width: 8),
                                Text('Language', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppTheme.textDark)),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Wrap(
                              spacing: 12,
                              runSpacing: 12,
                              children: languages.map((lang) => GestureDetector(
                                onTap: () {
                                  _saveLanguage(lang);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Language changed to $lang'), backgroundColor: AppTheme.primaryColor, duration: const Duration(seconds: 2)),
                                  );
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
                                  decoration: BoxDecoration(
                                    color: _selectedLanguage == lang ? AppTheme.primaryColor : const Color(0xFFEEF2FE),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        lang,
                                        style: TextStyle(
                                          color: _selectedLanguage == lang ? Colors.white : AppTheme.textDark,
                                          fontSize: 13,
                                          fontWeight: _selectedLanguage == lang ? FontWeight.w600 : FontWeight.w500,
                                        ),
                                      ),
                                      if (_selectedLanguage == lang) ...[
                                        const SizedBox(width: 6),
                                        const Icon(Icons.check_circle_outline, color: Colors.white, size: 14),
                                      ],
                                    ],
                                  ),
                                ),
                              )).toList(),
                            ),
                          ],
                        ),
                      ),

                      // ── App Settings ──────────────────────────────────────
                      _SectionContainer(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('App Settings', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppTheme.textDark)),
                            const SizedBox(height: 16),
                            Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              decoration: BoxDecoration(color: const Color(0xFFF7F9FC), borderRadius: BorderRadius.circular(12)),
                              child: Row(
                                children: [
                                  const Icon(Icons.notifications_active_outlined, color: AppTheme.textDark, size: 22),
                                  const SizedBox(width: 12),
                                  const Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('Push Notifications', style: TextStyle(color: AppTheme.textDark, fontSize: 15, fontWeight: FontWeight.w500)),
                                        SizedBox(height: 2),
                                        Text('Scan reminders & health tips', style: TextStyle(color: AppTheme.textMuted, fontSize: 11)),
                                      ],
                                    ),
                                  ),
                                  Switch(
                                    value: _notificationsEnabled,
                                    onChanged: (v) => _saveNotifications(v),
                                    activeColor: Colors.white,
                                    activeTrackColor: AppTheme.primaryColor,
                                  ),
                                ],
                              ),
                            ),
                            const _SettingsTile(
                              title: 'Data Privacy',
                              subtitle: 'Manage how your data is used',
                              icon: Icons.shield_outlined,
                              trailing: Icon(Icons.chevron_right, color: Colors.grey),
                            ),
                            const _SettingsTile(
                              title: 'Appearance',
                              icon: Icons.dark_mode_outlined,
                              trailing: Text('Light Mode', style: TextStyle(color: AppTheme.textDark, fontSize: 13, fontWeight: FontWeight.w600)),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 8),

                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () {
                            context.read<AuthProvider>().logout();
                            context.go('/login');
                          },
                          icon: const Icon(Icons.logout, size: 20),
                          label: const Text('Sign Out'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppTheme.dangerRed,
                            side: const BorderSide(color: AppTheme.dangerLight),
                            backgroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Center(
                        child: TextButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.help_outline, color: AppTheme.textDark, size: 18),
                          label: const Text('Help & Support', style: TextStyle(color: AppTheme.textDark, fontWeight: FontWeight.w600)),
                        ),
                      ),
                      const SizedBox(height: 40),
                    ]),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

// ── Helper Widgets ─────────────────────────────────────────────────────────────

class _SectionContainer extends StatelessWidget {
  final Widget child;
  const _SectionContainer({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 2))],
      ),
      child: child,
    );
  }
}

class _AllergyChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback? onDelete;

  const _AllergyChip({required this.label, required this.icon, this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 16, right: 8, top: 4, bottom: 4),
      decoration: BoxDecoration(color: const Color(0xFFE8ECEB), borderRadius: BorderRadius.circular(20)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: const Color(0xFF4A5568)),
          const SizedBox(width: 6),
          Text(label, style: const TextStyle(color: Color(0xFF4A5568), fontSize: 13, fontWeight: FontWeight.w500)),
          const SizedBox(width: 4),
          InkWell(
            onTap: onDelete,
            child: const Padding(
              padding: EdgeInsets.all(4.0),
              child: Icon(Icons.close, size: 14, color: Color(0xFF4A5568)),
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData icon;
  final Widget trailing;

  const _SettingsTile({required this.title, this.subtitle, required this.icon, required this.trailing});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(color: const Color(0xFFF7F9FC), borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.textDark, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: AppTheme.textDark, fontSize: 15, fontWeight: FontWeight.w500)),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(subtitle!, style: TextStyle(color: AppTheme.textMuted, fontSize: 11)),
                ],
              ],
            ),
          ),
          trailing,
        ],
      ),
    );
  }
}
