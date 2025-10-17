import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:camera/camera.dart';
import 'camera_state.dart';
import 'camera_event.dart';

class CameraBloc extends Bloc<CameraEvent, CameraState> {
  CameraController? _controller;
  List<CameraDescription>? _cameras;

  CameraBloc() : super(CameraInitial()) {
    // Register event handlers
    on<CameraInitialized>(_onInitialized);
    on<CameraFlashToggled>(_onFlashToggled);

    // Start initialization right away
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    // Only emit Loading if we are not already in a failure/ready state
    if (state is! CameraFailure) {
      emit(CameraLoading());
    }

    try {
      _cameras = await availableCameras();
      if (_cameras!.isEmpty) {
        emit(const CameraFailure("No cameras available."));
        return;
      }

      _controller = CameraController(
        _cameras!.first,
        ResolutionPreset.high,
        enableAudio: false,
      );

      await _controller!.initialize();
      add(CameraInitialized());
    } catch (e) {
      emit(CameraFailure(e.toString()));
    }
  }

  void _onInitialized(CameraInitialized event, Emitter<CameraState> emit) {
    if (_controller != null && _controller!.value.isInitialized) {
      emit(CameraReady(controller: _controller!));
    } else {
      emit(const CameraFailure("Camera initialization failed."));
    }
  }

  Future<void> _onFlashToggled(
    CameraFlashToggled event,
    Emitter<CameraState> emit,
  ) async {
    if (state is CameraReady) {
      final currentState = state as CameraReady;
      final bool newFlashState = !currentState.isFlashOn;

      await currentState.controller.setFlashMode(
        newFlashState ? FlashMode.torch : FlashMode.off,
      );

      // Emit the new state with the updated flash status
      emit(
        CameraReady(
          controller: currentState.controller,
          isFlashOn: newFlashState,
        ),
      );
    }
  }

  // Action: Capture Image (remains a function call for immediate return)
  Future<String?> captureImage() async {
    if (state is CameraReady) {
      final currentState = state as CameraReady;
      if (currentState.controller.value.isInitialized) {
        final image = await currentState.controller.takePicture();
        return image.path;
      }
    }
    return null;
  }

  @override
  Future<void> close() {
    _controller?.dispose();
    return super.close();
  }
}
