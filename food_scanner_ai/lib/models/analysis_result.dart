class AnalysisResult {
  final List<String> dangerous;
  final int nutritionScore;
  final String riskLevel;
  final String warning;
  final String rawImageBase64;
  final List<String> ingredients;
  final String rawOcrText;

  AnalysisResult({
    required this.dangerous,
    required this.nutritionScore,
    required this.riskLevel,
    required this.warning,
    required this.rawImageBase64,
    required this.ingredients,
    this.rawOcrText = '',
  });

  factory AnalysisResult.fromJson(Map<String, dynamic> json, String base64, List<String> parsedIngredients, String rawText) {
    return AnalysisResult(
      dangerous: List<String>.from(json['dangerous'] ?? []),
      nutritionScore: json['nutrition_score'] ?? 0,
      riskLevel: json['risk_level'] ?? 'Unknown',
      warning: json['warning'] ?? '',
      rawImageBase64: base64,
      ingredients: parsedIngredients,
      rawOcrText: json['raw_text'] ?? rawText,
    );
  }
}
