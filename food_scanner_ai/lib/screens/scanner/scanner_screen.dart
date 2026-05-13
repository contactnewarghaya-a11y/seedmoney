import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../providers/scan_provider.dart';
import '../../providers/history_provider.dart';
import '../../core/theme/app_theme.dart';
import '../../services/image_service.dart';

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  CameraController? _controller;
  bool _isCameraInitialized = false;
  bool _isFlashOn = false;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isNotEmpty) {
        _controller = CameraController(cameras.first, ResolutionPreset.max, enableAudio: false);
        await _controller!.initialize();
        if (mounted) setState(() => _isCameraInitialized = true);
      }
    } catch (e) {
      debugPrint("Camera init error: $e");
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _toggleFlash() async {
    if (_controller == null || !_controller!.value.isInitialized) return;
    try {
      _isFlashOn = !_isFlashOn;
      await _controller!.setFlashMode(_isFlashOn ? FlashMode.torch : FlashMode.off);
      setState(() {});
    } catch (_) {}
  }

  Future<void> _captureImage() async {
    if (_controller == null || !_controller!.value.isInitialized || _controller!.value.isTakingPicture) return;
    try {
      final XFile image = await _controller!.takePicture();
      if (!mounted) return;
      final historyProv = context.read<HistoryProvider>();
      final success = await context.read<ScanProvider>().processImage(image.path, historyProvider: historyProv);
      if (success && mounted) context.go('/result');
    } catch (e) {
      debugPrint("Capture error: $e");
    }
  }

  Future<void> _pickFromGallery() async {
    final imageService = ImageService();
    final image = await imageService.pickImageFromGallery();
    if (image != null && mounted) {
      final historyProv = context.read<HistoryProvider>();
      final success = await context.read<ScanProvider>().processImage(image.path, historyProvider: historyProv);
      if (success && mounted) context.go('/result');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isProcessing = context.watch<ScanProvider>().isProcessing;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Camera preview
          if (_isCameraInitialized && _controller != null)
            Positioned.fill(
              child: CameraPreview(_controller!),
            )
          else
            const Center(child: CircularProgressIndicator(color: Colors.white)),

          // Top App Bar
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Logo area
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: Text(
                      'NutriScan',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 17,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(50)),
                    child: IconButton(
                      icon: const Icon(Icons.settings_outlined, color: Colors.black87),
                      onPressed: () {},
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Viewfinder with corner brackets
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    // Frosted background for viewfinder
                    Container(
                      width: 290,
                      height: 210,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    // Corner brackets
                    SizedBox(
                      width: 290,
                      height: 210,
                      child: CustomPaint(painter: _CornerBracketPainter()),
                    ),
                    // Center icon + text
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.barcode_reader, color: Colors.white.withValues(alpha: 0.7), size: 40),
                        const SizedBox(height: 12),
                        const Text(
                          'Align Ingredient Label',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 16),
                        ),
                      ],
                    ),
                  ],
                ).animate(onPlay: (c) => c.repeat(reverse: true)).custom(
                  duration: 2.seconds,
                  builder: (_, val, child) => Opacity(opacity: 0.7 + val * 0.3, child: child),
                ),

                const SizedBox(height: 32),

                // Flash and Gallery inline buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _CamActionBtn(
                      icon: _isFlashOn ? Icons.flash_on : Icons.flash_off,
                      onTap: _toggleFlash,
                    ),
                    const SizedBox(width: 20),
                    _CamActionBtn(
                      icon: Icons.image_outlined,
                      onTap: _pickFromGallery,
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Hint card
          Positioned(
            bottom: 180,
            left: 24,
            right: 24,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.15), blurRadius: 20)],
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: AppTheme.primaryColor, size: 20),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Align the ingredient list within the frame for best results.',
                      style: TextStyle(fontSize: 13, color: Colors.black87, fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
            ).animate().slideY(begin: 0.2).fadeIn(delay: 300.ms),
          ),

          // Capture button + label
          Positioned(
            bottom: 60,
            left: 0,
            right: 0,
            child: Column(
              children: [
                GestureDetector(
                  onTap: isProcessing ? null : _captureImage,
                  child: Container(
                    width: 76,
                    height: 76,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.2),
                      border: Border.all(color: Colors.white, width: 3),
                    ),
                    child: Center(
                      child: isProcessing
                          ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 3)
                          : Container(
                              width: 58,
                              height: 58,
                              decoration: BoxDecoration(shape: BoxShape.circle, color: AppTheme.primaryColor),
                              child: const Icon(Icons.document_scanner_outlined, color: Colors.white, size: 28),
                            ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'SCAN LABEL',
                  style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 1.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CamActionBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _CamActionBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.15),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white.withValues(alpha: 0.4), width: 1.5),
        ),
        child: Icon(icon, color: Colors.white, size: 22),
      ),
    );
  }
}

// Custom painter for corner bracket viewfinder
class _CornerBracketPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF4CAF50)
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    const len = 28.0;
    const r = 12.0;

    // Top-left
    canvas.drawLine(Offset(r, 0), Offset(r + len, 0), paint);
    canvas.drawLine(Offset(0, r), Offset(0, r + len), paint);
    canvas.drawArc(const Rect.fromLTWH(0, 0, r * 2, r * 2), 3.14159, 3.14159 / 2, false, paint);

    // Top-right
    canvas.drawLine(Offset(size.width - r, 0), Offset(size.width - r - len, 0), paint);
    canvas.drawLine(Offset(size.width, r), Offset(size.width, r + len), paint);
    canvas.drawArc(Rect.fromLTWH(size.width - r * 2, 0, r * 2, r * 2), 3.14159 * 1.5, 3.14159 / 2, false, paint);

    // Bottom-left
    canvas.drawLine(Offset(r, size.height), Offset(r + len, size.height), paint);
    canvas.drawLine(Offset(0, size.height - r), Offset(0, size.height - r - len), paint);
    canvas.drawArc(Rect.fromLTWH(0, size.height - r * 2, r * 2, r * 2), 3.14159 / 2, 3.14159 / 2, false, paint);

    // Bottom-right
    canvas.drawLine(Offset(size.width - r, size.height), Offset(size.width - r - len, size.height), paint);
    canvas.drawLine(Offset(size.width, size.height - r), Offset(size.width, size.height - r - len), paint);
    canvas.drawArc(Rect.fromLTWH(size.width - r * 2, size.height - r * 2, r * 2, r * 2), 0, 3.14159 / 2, false, paint);
  }

  @override
  bool shouldRepaint(_) => false;
}
