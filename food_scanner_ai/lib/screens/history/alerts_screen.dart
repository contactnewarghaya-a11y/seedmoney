import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/alert_provider.dart';

class AlertsScreen extends StatefulWidget {
  const AlertsScreen({super.key});

  @override
  State<AlertsScreen> createState() => _AlertsScreenState();
}

class _AlertsScreenState extends State<AlertsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      body: SafeArea(
        child: Consumer<AlertProvider>(
          builder: (context, alertProv, child) {
            final alerts = alertProv.alerts;
            
            return CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 18,
                          backgroundImage: const NetworkImage('https://i.pravatar.cc/150?img=11'),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'NutriScan AI',
                          style: TextStyle(
                            color: AppTheme.primaryColor,
                            fontWeight: FontWeight.w800,
                            fontSize: 22,
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.notifications_none_rounded, color: AppTheme.textDark),
                          onPressed: () {},
                        ),
                      ],
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Your Alerts',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w900,
                            color: AppTheme.textDark,
                            height: 1.1,
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Stay informed about your health data and safety updates.',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppTheme.textMuted,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 24),
                        
                        // Overview
                        Container(
                          padding: const EdgeInsets.all(20),
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
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'OVERVIEW',
                                style: TextStyle(color: AppTheme.primaryLight, fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1.2),
                              ),
                              const SizedBox(height: 16),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('Unread Alerts', style: TextStyle(color: AppTheme.textDark, fontSize: 14, fontWeight: FontWeight.w500)),
                                  if (alertProv.unreadCount > 0)
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: AppTheme.primaryColor,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text('${alertProv.unreadCount} New', style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700)),
                                    )
                                  else
                                    const Text('0', style: TextStyle(color: AppTheme.textMuted, fontSize: 14, fontWeight: FontWeight.w500)),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('Urgent Recalls', style: TextStyle(color: AppTheme.textDark, fontSize: 14, fontWeight: FontWeight.w500)),
                                  if (alertProv.urgentCount > 0)
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: AppTheme.dangerLight,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text('${alertProv.urgentCount} Urgent', style: const TextStyle(color: AppTheme.dangerRed, fontSize: 11, fontWeight: FontWeight.w700)),
                                    )
                                  else
                                    const Text('0', style: TextStyle(color: AppTheme.textMuted, fontSize: 14, fontWeight: FontWeight.w500)),
                                ],
                              ),
                              const SizedBox(height: 20),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: alertProv.unreadCount > 0 ? () => alertProv.markAllAsRead() : null,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppTheme.primaryColor,
                                    disabledBackgroundColor: Colors.grey.shade300,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                    padding: const EdgeInsets.symmetric(vertical: 14),
                                  ),
                                  child: const Text('Mark all as read'),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        
                        if (alertProv.isLoading)
                          const Center(child: CircularProgressIndicator())
                        else if (alerts.isEmpty)
                          const Center(child: Text("No alerts found.", style: TextStyle(color: AppTheme.textMuted)))
                        else
                          ...alerts.map((a) {
                            final isUnread = !(a['read'] ?? false);
                            final isUrgent = a['urgent'] ?? false;
                            
                            IconData iconData = Icons.info_outline;
                            Color iconBgColor = const Color(0xFFE0E7FF);
                            Color iconColor = const Color(0xFF1E3A8A);
                            
                            if (isUrgent) {
                              iconData = Icons.warning_amber_rounded;
                              iconBgColor = AppTheme.dangerRed;
                              iconColor = Colors.white;
                            } else if (a['type'] == 'Personalized Health Tip') {
                              iconData = Icons.lightbulb_outline;
                              iconBgColor = AppTheme.primaryLightest;
                              iconColor = AppTheme.primaryColor;
                            }

                            return _AlertCard(
                              icon: iconData,
                              iconBgColor: iconBgColor,
                              iconColor: iconColor,
                              title: a['title'] ?? 'Alert',
                              time: 'Recent',
                              content: a['content'] ?? '',
                              contentColor: isUrgent ? AppTheme.dangerRed : AppTheme.textDark,
                              bgColor: isUnread ? (isUrgent ? const Color(0xFFFEE2E2) : Colors.white) : const Color(0xFFF8FAFC),
                              titleColor: isUrgent ? AppTheme.dangerRed : AppTheme.textDark,
                              chips: a['tagLabel'] != null ? [
                                _AlertChip(
                                  label: a['tagLabel'], 
                                  color: isUrgent ? AppTheme.dangerRed : AppTheme.primaryColor, 
                                  bgColor: isUrgent ? (isUnread ? Colors.white : AppTheme.dangerLight) : AppTheme.primaryLightest
                                )
                              ] : [],
                            );
                          }),
                        
                        const SizedBox(height: 40),
                      ],
                    ),
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

class _AlertCard extends StatelessWidget {
  final IconData icon;
  final Color iconBgColor;
  final Color iconColor;
  final String title;
  final Color titleColor;
  final String time;
  final String content;
  final Color contentColor;
  final Color bgColor;
  final List<Widget> chips;

  const _AlertCard({
    required this.icon,
    required this.iconBgColor,
    required this.iconColor,
    required this.title,
    this.titleColor = AppTheme.textDark,
    required this.time,
    required this.content,
    this.contentColor = AppTheme.textDark,
    this.bgColor = Colors.white,
    this.chips = const [],
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: bgColor == Colors.white ? [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ] : null,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconBgColor,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: titleColor,
                          height: 1.2,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      time,
                      style: TextStyle(
                        fontSize: 11,
                        color: titleColor == AppTheme.textDark ? AppTheme.textMuted : titleColor.withValues(alpha: 0.8),
                      ),
                      textAlign: TextAlign.right,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  content,
                  style: TextStyle(
                    fontSize: 13,
                    color: contentColor == AppTheme.textDark ? AppTheme.textDark : contentColor,
                    height: 1.4,
                  ),
                ),
                if (chips.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: chips,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AlertChip extends StatelessWidget {
  final String label;
  final Color color;
  final Color bgColor;

  const _AlertChip({required this.label, required this.color, required this.bgColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
