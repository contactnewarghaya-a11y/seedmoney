import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/history_provider.dart';
import '../../providers/profile_provider.dart';
import '../../models/scan_history.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      body: SafeArea(
        child: Consumer2<HistoryProvider, ProfileProvider>(
          builder: (context, historyProv, profileProv, child) {
            final profile = profileProv.profile;
            
            // Filter history
            List<ScanHistoryItem> filteredHistory = historyProv.history;
            if (_searchQuery.isNotEmpty) {
              filteredHistory = filteredHistory.where((item) {
                final ingredients = item.result.ingredients.join(' ').toLowerCase();
                return ingredients.contains(_searchQuery.toLowerCase());
              }).toList();
            }

            // Group by Today / Yesterday / Older
            final now = DateTime.now();
            final today = DateTime(now.year, now.month, now.day);
            final yesterday = today.subtract(const Duration(days: 1));

            List<ScanHistoryItem> todayItems = [];
            List<ScanHistoryItem> yesterdayItems = [];
            List<ScanHistoryItem> olderItems = [];

            for (var item in filteredHistory) {
              final itemDate = DateTime(item.createdAt.year, item.createdAt.month, item.createdAt.day);
              if (itemDate == today) {
                todayItems.add(item);
              } else if (itemDate == yesterday) {
                yesterdayItems.add(item);
              } else {
                olderItems.add(item);
              }
            }

            return CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 18,
                          backgroundImage: profile.avatarUrl != null ? NetworkImage(profile.avatarUrl!) : const NetworkImage('https://i.pravatar.cc/150?img=11'),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Hi, ${profile.fullName.split(' ').first}',
                          style: const TextStyle(
                            color: AppTheme.primaryColor,
                            fontWeight: FontWeight.w800,
                            fontSize: 22,
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.notifications_none_rounded, color: AppTheme.textDark),
                          onPressed: () => context.push('/alerts'),
                        ),
                      ],
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        TextField(
                          controller: _searchController,
                          onChanged: (val) {
                            setState(() {
                              _searchQuery = val;
                            });
                          },
                          decoration: InputDecoration(
                            hintText: 'Search product history...',
                            hintStyle: TextStyle(color: AppTheme.textMuted, fontSize: 15),
                            prefixIcon: const Icon(Icons.search, color: AppTheme.textMuted),
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: const EdgeInsets.symmetric(vertical: 16),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Colors.grey.shade300),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Colors.grey.shade300),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        if (historyProv.history.isNotEmpty)
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed: () {
                                historyProv.clearHistory();
                              },
                              icon: const Icon(Icons.delete_outline, size: 20),
                              label: const Text('Clear History'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppTheme.primaryColor,
                                side: BorderSide(color: Colors.grey.shade300),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                backgroundColor: Colors.white,
                              ),
                            ),
                          ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
                if (filteredHistory.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.history, size: 64, color: Colors.grey.shade300),
                          const SizedBox(height: 16),
                          Text('No scan history found', style: TextStyle(color: AppTheme.textMuted, fontSize: 16)),
                        ],
                      ),
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final List<Widget> children = [];
                          if (todayItems.isNotEmpty && index == 0) {
                            children.add(const Padding(
                              padding: EdgeInsets.only(bottom: 12),
                              child: Text('TODAY', style: TextStyle(color: AppTheme.textMuted, fontSize: 13, letterSpacing: 1.2)),
                            ));
                            children.addAll(todayItems.map((item) => _HistoryCard(item: item)));
                            children.add(const SizedBox(height: 12));
                          }
                          
                          if (yesterdayItems.isNotEmpty && index == (todayItems.isNotEmpty ? 1 : 0)) {
                            children.add(const Padding(
                              padding: EdgeInsets.only(bottom: 12),
                              child: Text('YESTERDAY', style: TextStyle(color: AppTheme.textMuted, fontSize: 13, letterSpacing: 1.2)),
                            ));
                            children.addAll(yesterdayItems.map((item) => _HistoryCard(item: item)));
                            children.add(const SizedBox(height: 12));
                          }
                          
                          if (olderItems.isNotEmpty && index == (todayItems.isNotEmpty ? 1 : 0) + (yesterdayItems.isNotEmpty ? 1 : 0)) {
                            children.add(const Padding(
                              padding: EdgeInsets.only(bottom: 12),
                              child: Text('OLDER', style: TextStyle(color: AppTheme.textMuted, fontSize: 13, letterSpacing: 1.2)),
                            ));
                            children.addAll(olderItems.map((item) => _HistoryCard(item: item)));
                          }

                          if (index == (todayItems.isNotEmpty ? 1 : 0) + (yesterdayItems.isNotEmpty ? 1 : 0) + (olderItems.isNotEmpty ? 1 : 0)) {
                            return const SizedBox(height: 80); // Bottom padding for FAB
                          }

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: children,
                          );
                        },
                        childCount: (todayItems.isNotEmpty ? 1 : 0) + (yesterdayItems.isNotEmpty ? 1 : 0) + (olderItems.isNotEmpty ? 1 : 0) + 1,
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.go('/scanner'),
        backgroundColor: AppTheme.primaryColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: const Icon(Icons.qr_code_scanner, color: Colors.white),
      ),
    );
  }
}

class _HistoryCard extends StatelessWidget {
  final ScanHistoryItem item;

  const _HistoryCard({required this.item});

  @override
  Widget build(BuildContext context) {
    bool isSafe = item.result.riskLevel.toLowerCase() == 'safe';
    bool isWarning = item.result.riskLevel.toLowerCase() == 'moderate';
    String status = item.result.riskLevel;
    
    if (item.result.dangerous.isNotEmpty) {
      status = 'Allergen Detected';
      isSafe = false;
      isWarning = false;
    } else if (status.toLowerCase() == 'high') {
      isSafe = false;
      isWarning = false;
    }

    Color chipBgColor = isSafe ? AppTheme.primaryLightest : (isWarning ? Colors.grey.shade400 : AppTheme.dangerLight);
    Color chipTextColor = isSafe ? AppTheme.primaryColor : (isWarning ? Colors.black87 : AppTheme.dangerRed);
    IconData chipIcon = isSafe ? Icons.check_circle_outline : (isWarning ? Icons.error_outline : Icons.warning_amber_rounded);

    // Format time
    String timeStr = '${item.createdAt.hour.toString().padLeft(2, '0')}:${item.createdAt.minute.toString().padLeft(2, '0')}';
    
    // Attempt to parse ingredients for a title
    String title = 'Scanned Product';
    if (item.result.ingredients.isNotEmpty) {
      title = item.result.ingredients.first;
      if (title.length > 20) title = '${title.substring(0, 20)}...';
    }

    Widget imageWidget;
    if (item.result.rawImageBase64.isNotEmpty) {
      try {
        imageWidget = Image.memory(
          base64Decode(item.result.rawImageBase64),
          width: 72,
          height: 72,
          fit: BoxFit.cover,
        );
      } catch (e) {
        imageWidget = _placeholderImage();
      }
    } else {
      imageWidget = _placeholderImage();
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: imageWidget,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textDark,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Scanned at $timeStr',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppTheme.textMuted,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: chipBgColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(chipIcon, size: 14, color: chipTextColor),
                      const SizedBox(width: 4),
                      Text(
                        status,
                        style: TextStyle(
                          color: chipTextColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _placeholderImage() {
    return Image.network(
      'https://images.unsplash.com/photo-1542838132-92c53300491e?auto=format&fit=crop&q=80&w=200',
      width: 72,
      height: 72,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => Container(
        width: 72,
        height: 72,
        color: Colors.grey.shade200,
        child: const Icon(Icons.image_not_supported, color: Colors.grey),
      ),
    );
  }
}
