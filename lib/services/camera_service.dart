import 'dart:typed_data';
import 'package:camera/camera.dart';

class CameraService {
  static CameraService? _instance;

  static CameraService get instance {
    _instance ??= CameraService._();
    return _instance!;
  }

  CameraService._();

  CameraController? _controller;
  List<CameraDescription>? _cameras;
  bool _isInitialized = false;

  CameraController? get controller => _controller;

  bool get isInitialized => _isInitialized;

  Future<void> initialize() async {
    try {
      _cameras = await availableCameras();
      if (_cameras == null) return;
      if (_cameras!.isEmpty) return;

      _controller = CameraController(
        _cameras!.first,
        ResolutionPreset.high,
        enableAudio: false,
      );

      await _controller!.initialize();
      _isInitialized = true;
    } catch (e) {
      print("Error initializing camera: $e");
    }
  }

  Future<Uint8List?> takePicture() async {
    if (!_isInitialized || _controller == null) return null;

    try {
      final XFile image = await _controller!.takePicture();
      return await image.readAsBytes();
    } catch (e) {
      print("Error taking picture: $e");
      return null;
    }
  }

  void dispose() {
    _controller?.dispose();
    _isInitialized = false;
  }

  Future<void> setFlashMode(FlashMode mode) async {
    if (_controller != null) {
      await _controller!.setFlashMode(mode);
    }
  }
}
