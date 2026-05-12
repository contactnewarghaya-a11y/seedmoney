import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../providers/auth_provider.dart';
import '../../providers/scan_provider.dart';
import '../../providers/profile_provider.dart';
import '../../services/image_service.dart';
import '../../core/theme/app_theme.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200.0,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: const Text('NutriScan', style: TextStyle(fontWeight: FontWeight.bold)),
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppTheme.primaryColor, AppTheme.secondaryColor],
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.spa, color: Colors.white, size: 60)
                          .animate()
                          .scale(duration: 500.ms, curve: Curves.easeOutBack)
                          .fadeIn(),
                      const SizedBox(height: 8),
                      const Text(
                        "Your Personal Food Guardian",
                        style: TextStyle(color: Colors.white70, fontSize: 16),
                      ).animate().fadeIn(delay: 300.ms),
                    ],
                  ),
                ),
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.logout, color: Colors.white),
                onPressed: () {
                  context.read<AuthProvider>().logout();
                  context.go('/login');
                },
              )
            ],
          ),
        SliverPadding(
            padding: const EdgeInsets.all(24.0),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Stats Dashboard Widget
                Consumer<ProfileProvider>(
                  builder: (context, profileProvider, child) {
                    final profile = profileProvider.profile;
                    return Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          )
                        ],
                        border: Border.all(color: Colors.grey.shade100),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _StatColumn(
                            title: "Scans",
                            value: "${profile.totalScans}",
                            icon: Icons.document_scanner,
                            color: Colors.blue,
                          ).animate().scale(delay: 400.ms),
                          Container(width: 1, height: 40, color: Colors.grey.shade200),
                          _StatColumn(
                            title: "Points",
                            value: "${profile.rewardPoints}",
                            icon: Icons.stars_rounded,
                            color: Colors.amber.shade600,
                          ).animate().scale(delay: 500.ms),
                        ],
                      ),
                    ).animate().slideY(begin: 0.2).fadeIn(delay: 200.ms);
                  },
                ),
                const SizedBox(height: 32),

                Text(
                  'What would you like to do today?',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                ).animate().slideX(begin: -0.1).fadeIn(delay: 600.ms),
                const SizedBox(height: 24),
                
                // Cards Grid
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.9,
                  children: [
                    _DashboardCard(
                      title: 'Scan Food',
                      subtitle: 'Use Camera',
                      icon: Icons.camera_alt_rounded,
                      color: Colors.blue.shade400,
                      onTap: () => context.go('/scanner'),
                    ).animate().scale(delay: 100.ms, duration: 400.ms, curve: Curves.easeOut),
                    
                    _DashboardCard(
                      title: 'Upload',
                      subtitle: 'From Gallery',
                      icon: Icons.image_rounded,
                      color: Colors.green.shade400,
                      onTap: () async {
                        final imageService = ImageService();
                        final image = await imageService.pickImageFromGallery();
                        if (image != null && context.mounted) {
                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (_) => const Center(child: CircularProgressIndicator(color: AppTheme.primaryColor)),
                          );
                          final success = await context.read<ScanProvider>().processImage(image.path);
                          if (context.mounted) {
                             Navigator.of(context).pop(); 
                             if (success) {
                               context.go('/result');
                             } else {
                               ScaffoldMessenger.of(context).showSnackBar(
                                 const SnackBar(content: Text('Failed to process image.')),
                               );
                             }
                          }
                        }
                      },
                    ).animate().scale(delay: 200.ms, duration: 400.ms, curve: Curves.easeOut),

                    _DashboardCard(
                      title: 'History',
                      subtitle: 'Past Scans',
                      icon: Icons.history_rounded,
                      color: Colors.orange.shade400,
                      onTap: () => context.go('/history'),
                    ).animate().scale(delay: 300.ms, duration: 400.ms, curve: Curves.easeOut),

                    _DashboardCard(
                      title: 'Profile',
                      subtitle: 'Health Settings',
                      icon: Icons.person_rounded,
                      color: Colors.purple.shade400,
                      onTap: () => context.go('/profile'),
                    ).animate().scale(delay: 400.ms, duration: 400.ms, curve: Curves.easeOut),
                  ],
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class _DashboardCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _DashboardCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 8,
      shadowColor: color.withValues(alpha: 0.3),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                color.withValues(alpha: 0.8),
                color,
              ],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(icon, size: 32, color: Colors.white),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.white.withValues(alpha: 0.8),
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StatColumn extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatColumn({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }
}
