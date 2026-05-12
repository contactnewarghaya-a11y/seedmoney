import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

class ImageService {
  final ImagePicker _picker = ImagePicker();

  Future<XFile?> pickImageFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      return image;
    } catch (e) {
      debugPrint("Error picking image: $e");
      return null;
    }
  }

  Future<String?> compressAndGetBase64(String imagePath) async {
    try {
      // Compress the image
      final Uint8List? compressedBytes = await FlutterImageCompress.compressWithFile(
        imagePath,
        quality: 98, // High quality is critical for OCR
      );

      if (compressedBytes != null) {
        // Convert to Base64
        return base64Encode(compressedBytes);
      }
      return null;
    } catch (e) {
      debugPrint("Error compressing image: $e");
      return null;
    }
  }
}
