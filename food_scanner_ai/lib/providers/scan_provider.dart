import 'package:flutter/foundation.dart';
import '../services/image_service.dart';
import '../api/scanner_api.dart';
import '../models/analysis_result.dart';

class ScanProvider with ChangeNotifier {
  final ImageService _imageService = ImageService();
  final ScannerApi _scannerApi = ScannerApi();
  
  bool _isProcessing = false;
  String? _base64Image;
  AnalysisResult? _lastResult;

  bool get isProcessing => _isProcessing;
  String? get base64Image => _base64Image;
  AnalysisResult? get lastResult => _lastResult;

  Future<bool> processImage(String imagePath) async {
    _isProcessing = true;
    _lastResult = null; // Clear previous
    notifyListeners();

    try {
      // 1. Compress and convert to Base64
      _base64Image = await _imageService.compressAndGetBase64(imagePath);
      
      if (_base64Image != null) {
        // 2. Extract Text via OCR API
        final ocrResponse = await _scannerApi.extractText(_base64Image!);
        final ingredients = List<String>.from(ocrResponse['ingredients']);
        final rawText = ocrResponse['raw_text'] as String;

        // 3. Analyze Ingredients via GLM AI API
        final aiResponse = await _scannerApi.analyzeIngredients(ingredients, rawText);

        // 4. Store Result
        _lastResult = AnalysisResult.fromJson(aiResponse, _base64Image!, ingredients, rawText);
        
        return true;
      }
    } catch (e) {
      debugPrint("Error processing image in provider: $e");
    } finally {
      _isProcessing = false;
      notifyListeners();
    }
    
    return false;
  }

  void reset() {
    _base64Image = null;
    _lastResult = null;
    _isProcessing = false;
    notifyListeners();
  }
}
