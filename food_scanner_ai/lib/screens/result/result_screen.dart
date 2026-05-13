import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../providers/scan_provider.dart';
import '../../core/theme/app_theme.dart';

class ResultScreen extends StatelessWidget {
  const ResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final result = context.watch<ScanProvider>().lastResult;

    if (result == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Analysis Result')),
        body: const Center(child: Text('No result found.')),
      );
    }

    final bool isDangerous = result.riskLevel.toLowerCase() == 'high' ||
        result.riskLevel.toLowerCase() == 'dangerous';
    final bool isSafe = result.riskLevel.toLowerCase() == 'safe';
    final double percent = (result.nutritionScore / 10).clamp(0.0, 1.0);

    // Parse nutritional hints from the warning text
    final int calories = _extractNutrient(result.warning, 'calorie') ?? 0;

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      body: CustomScrollView(
        slivers: [
          // Hero Food Image + AppBar
          SliverAppBar(
            expandedHeight: 240,
            pinned: true,
            backgroundColor: Colors.white,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () {
                context.read<ScanProvider>().reset();
                context.go('/dashboard');
              },
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  if (result.rawImageBase64.isNotEmpty)
                    Image.memory(base64Decode(result.rawImageBase64), fit: BoxFit.cover)
                  else
                    Container(color: Colors.grey.shade200, child: const Icon(Icons.image, size: 60, color: Colors.grey)),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.black.withValues(alpha: 0.3), Colors.transparent],
                      ),
                    ),
                  ),
                  // Product Scanned chip
                  Positioned(
                    bottom: 16,
                    left: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor,
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: const Text('Product Scanned', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700)),
                    ),
                  ),
                ],
              ),
            ),
          ),

          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Product Name & Risk Level
                Text(
                  result.ingredients.isNotEmpty ? result.ingredients.first : 'Scanned Product',
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: AppTheme.textDark),
                ).animate().fadeIn().slideX(begin: -0.1),

                const SizedBox(height: 16),

                // Allergen Alert Card
                if (result.dangerous.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.red.shade200),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(color: Colors.red.shade100, shape: BoxShape.circle),
                          child: Icon(Icons.warning_amber_rounded, color: Colors.red.shade700, size: 20),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Contains ${result.dangerous.join(', ')}',
                                  style: TextStyle(fontWeight: FontWeight.w800, color: Colors.red.shade800, fontSize: 15)),
                              Text('This product contains severe allergens. Do not consume if you have an allergy.',
                                  style: TextStyle(color: Colors.red.shade600, fontSize: 12)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ).animate().fadeIn(delay: 200.ms).slideY(begin: -0.1),

                const SizedBox(height: 20),

                // Nutritional Metric Circles
                Row(
                  children: [
                    Expanded(
                      child: _NutritionalCircle(
                        label: 'Nutrition Score',
                        value: '${result.nutritionScore}/10',
                        percent: percent,
                        color: isSafe ? Colors.green : isDangerous ? Colors.red : Colors.orange,
                        badge: isSafe ? 'Good' : isDangerous ? 'Poor' : 'Moderate',
                        badgeColor: isSafe ? Colors.green : isDangerous ? Colors.red : Colors.orange,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _NutritionalCircle(
                        label: 'Risk Level',
                        value: result.riskLevel,
                        percent: isSafe ? 0.9 : isDangerous ? 0.2 : 0.5,
                        color: isSafe ? Colors.green : isDangerous ? Colors.red : Colors.orange,
                        badge: result.riskLevel,
                        badgeColor: isSafe ? Colors.green : isDangerous ? Colors.red : Colors.orange,
                      ),
                    ),
                  ],
                ).animate().fadeIn(delay: 300.ms),

                const SizedBox(height: 20),

                // Detected Ingredients Card
                _ResultCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Text('Detected Ingredients', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(50),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.document_scanner_outlined, size: 12, color: AppTheme.primaryColor),
                                const SizedBox(width: 4),
                                Text('OCR Active', style: TextStyle(fontSize: 11, color: AppTheme.primaryColor, fontWeight: FontWeight.w700)),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: result.ingredients.map((ingredient) {
                          final isDangerous = result.dangerous.contains(ingredient);
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: isDangerous ? Colors.red.shade50 : Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(50),
                              border: Border.all(color: isDangerous ? Colors.red.shade300 : Colors.transparent),
                            ),
                            child: Text(
                              ingredient,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: isDangerous ? FontWeight.w700 : FontWeight.w500,
                                color: isDangerous ? Colors.red.shade700 : Colors.black87,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      if (result.ingredients.isEmpty)
                        const Text('No ingredients detected.', style: TextStyle(color: Colors.grey)),
                      const SizedBox(height: 12),
                      Text('* Analysis based on scanned packaging image. Always cross-verify with physical labels.',
                          style: TextStyle(color: AppTheme.textMuted, fontSize: 11)),
                    ],
                  ),
                ).animate().slideY(begin: 0.1, delay: 400.ms).fadeIn(),

                const SizedBox(height: 16),

                // Health Score Card
                _ResultCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.green.shade50,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(Icons.favorite_outline, color: AppTheme.primaryColor, size: 22),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Health Score: ${result.nutritionScore * 10}/100',
                                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
                              Text(
                                result.nutritionScore >= 7 ? 'Good nutritional profile' : 'Low nutritional score',
                                style: TextStyle(color: AppTheme.textMuted, fontSize: 12),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Text(result.warning,
                          style: const TextStyle(fontSize: 13, color: Colors.black87, height: 1.5)),
                      const SizedBox(height: 12),
                      GestureDetector(
                        onTap: () {},
                        child: Text('View full breakdown →',
                            style: TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.w700, fontSize: 13)),
                      ),
                    ],
                  ),
                ).animate().slideY(begin: 0.1, delay: 500.ms).fadeIn(),

                const SizedBox(height: 16),

                // Raw OCR Data (collapsed by default)
                if (result.rawOcrText.isNotEmpty)
                  ExpansionTile(
                    tilePadding: EdgeInsets.zero,
                    title: const Text('Raw Label Data Extract',
                        style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Text(result.rawOcrText,
                            style: const TextStyle(fontFamily: 'monospace', fontSize: 12, color: Colors.black54, height: 1.6)),
                      ),
                    ],
                  ).animate().fadeIn(delay: 600.ms),

                const SizedBox(height: 40),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  int? _extractNutrient(String text, String nutrient) {
    final regex = RegExp(r'(\d+)\s*' + nutrient, caseSensitive: false);
    final match = regex.firstMatch(text);
    return match != null ? int.tryParse(match.group(1)!) : null;
  }
}

class _NutritionalCircle extends StatelessWidget {
  final String label;
  final String value;
  final double percent;
  final Color color;
  final String badge;
  final Color badgeColor;

  const _NutritionalCircle({
    required this.label,
    required this.value,
    required this.percent,
    required this.color,
    required this.badge,
    required this.badgeColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10)],
      ),
      child: Column(
        children: [
          CircularPercentIndicator(
            radius: 50,
            lineWidth: 10,
            percent: percent,
            center: Text(value, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14), textAlign: TextAlign.center),
            progressColor: color,
            backgroundColor: Colors.grey.shade100,
            circularStrokeCap: CircularStrokeCap.round,
            animation: true,
            animationDuration: 1200,
          ),
          const SizedBox(height: 10),
          Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: badgeColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(50),
            ),
            child: Text(badge, style: TextStyle(color: badgeColor, fontWeight: FontWeight.w700, fontSize: 11)),
          ),
        ],
      ),
    );
  }
}

class _ResultCard extends StatelessWidget {
  final Widget child;
  const _ResultCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10)],
      ),
      child: child,
    );
  }
}
