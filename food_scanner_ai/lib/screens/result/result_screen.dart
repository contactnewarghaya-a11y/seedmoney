import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../providers/scan_provider.dart';

class ResultScreen extends StatelessWidget {
  const ResultScreen({super.key});

  Color _getRiskColor(String riskLevel) {
    switch (riskLevel.toLowerCase()) {
      case 'safe':
        return Colors.green;
      case 'medium':
        return Colors.orange;
      case 'high':
      case 'dangerous':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final result = context.watch<ScanProvider>().lastResult;

    if (result == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Analysis Result')),
        body: const Center(child: Text('No result found.')),
      );
    }

    final riskColor = _getRiskColor(result.riskLevel);
    // Convert 10-point scale to percentage (e.g. 4 -> 0.4)
    final double percent = (result.nutritionScore / 10).clamp(0.0, 1.0);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Analysis Result'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            context.read<ScanProvider>().reset();
            context.go('/dashboard');
          },
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Food Image
              Container(
                height: 250,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  image: DecorationImage(
                    image: MemoryImage(base64Decode(result.rawImageBase64)),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              
              // Danger Alert Banner
              Container(
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                color: riskColor.withValues(alpha: 0.1),
                child: Row(
                  children: [
                    Icon(
                      result.riskLevel.toLowerCase() == 'safe' 
                          ? Icons.check_circle 
                          : Icons.warning_amber_rounded,
                      color: riskColor,
                      size: 32,
                    ).animate(onPlay: (controller) => controller.repeat(reverse: true)).scale(duration: 800.ms, begin: const Offset(0.9, 0.9)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Risk Level: ${result.riskLevel}',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: riskColor,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ),
                  ],
                ),
              ).animate().slideY(begin: -0.2).fadeIn(),

              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Warning/Recommendation Text
                    Text(
                      result.warning,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                            fontSize: 18,
                            height: 1.5,
                          ),
                    ).animate().fadeIn(delay: 200.ms).slideX(begin: 0.1),
                    const SizedBox(height: 32),

                    // Nutrition Score (percent_indicator)
                    Center(
                      child: Column(
                        children: [
                          Text(
                            'Nutrition Score',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const SizedBox(height: 16),
                          CircularPercentIndicator(
                            radius: 90.0,
                            lineWidth: 16.0,
                            percent: percent,
                            center: Text(
                              "${result.nutritionScore}/10",
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 36.0),
                            ),
                            circularStrokeCap: CircularStrokeCap.round,
                            progressColor: percent > 0.7 
                                ? Colors.green 
                                : percent > 0.4 
                                    ? Colors.orange 
                                    : Colors.red,
                            backgroundColor: Colors.grey.shade200,
                            animation: true,
                            animationDuration: 1500,
                          ).animate().scale(delay: 300.ms, curve: Curves.easeOutBack),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),

                    // Ingredients Card
                    Text(
                      'Detected Ingredients',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ).animate().fadeIn(delay: 500.ms),
                    const SizedBox(height: 12),
                    Card(
                      elevation: 4,
                      shadowColor: Colors.black12,
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide(color: Colors.grey.shade200),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Wrap(
                          spacing: 10.0,
                          runSpacing: 10.0,
                          children: result.ingredients.map((ingredient) {
                            final isDangerous = result.dangerous.contains(ingredient);
                            return Chip(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              label: Text(
                                ingredient,
                                style: TextStyle(
                                  color: isDangerous ? Colors.white : Colors.black87,
                                  fontWeight: isDangerous ? FontWeight.bold : FontWeight.w500,
                                ),
                              ),
                              backgroundColor: isDangerous ? Colors.red.shade500 : Colors.grey.shade100,
                              side: BorderSide(
                                color: isDangerous ? Colors.red.shade600 : Colors.transparent,
                              ),
                              elevation: isDangerous ? 2 : 0,
                            ).animate().fadeIn(delay: 600.ms).scale();
                          }).toList(),
                        ),
                      ),
                    ).animate().slideY(begin: 0.1, delay: 500.ms).fadeIn(),
                    
                    const SizedBox(height: 40),

                    // Raw OCR Data Collection Card
                    Text(
                      'Raw Label Data Extract',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ).animate().fadeIn(delay: 700.ms),
                    const SizedBox(height: 12),
                    Card(
                      elevation: 0,
                      color: Colors.black.withValues(alpha: 0.03),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(color: Colors.grey.shade300),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Text(
                          result.rawOcrText.isEmpty ? "No raw text available." : result.rawOcrText,
                          style: const TextStyle(
                            fontFamily: 'monospace',
                            color: Colors.black54,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ).animate().slideY(begin: 0.1, delay: 700.ms).fadeIn(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
