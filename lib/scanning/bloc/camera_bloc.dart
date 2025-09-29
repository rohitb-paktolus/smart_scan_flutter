import 'dart:typed_data';
import 'dart:ui';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../services/camera_service.dart';

part 'camera_event.dart';
part 'camera_state.dart';

class CameraBloc extends Bloc<CameraEvent, CameraState> {
  final ImagePicker _picker = ImagePicker();

  CameraBloc() : super(CameraInitial()) {
    on<InitializeCamera>(_onInitializeCamera);
    on<TakePicture>(_onTakePicture);
    on<PickFromGallery>(_onPickFromGallery);
    on<ToggleFlash>(_onToggleFlash);
  }

  Future<void> _onInitializeCamera(
      InitializeCamera event,
      Emitter<CameraState> emit,
      ) async {
    emit(CameraLoading());
    final permission = await Permission.camera.request();

    if (permission.isGranted) {
      await CameraService.instance.initialize();
      emit(CameraReady(
        controller: CameraService.instance.controller!,
        flashMode: FlashMode.off,
      ));
    } else {
      emit(CameraError("Camera permission denied"));
    }
  }

  Future<void> _onTakePicture(
      TakePicture event,
      Emitter<CameraState> emit,
      ) async {
    emit(CameraLoading());

    try {
      final imageBytes = await CameraService.instance.takePicture();

      if (imageBytes != null) {
        emit(CameraPictureTaken(
          imageBytes: imageBytes,
          corners: const [],
        ));
      } else {
        emit(CameraError("Failed to capture image"));
      }
    } catch (e) {
      emit(CameraError("Error taking picture: $e"));
    }
  }

  Future<void> _onPickFromGallery(
      PickFromGallery event,
      Emitter<CameraState> emit,
      ) async {
    emit(CameraLoading());

    try {
      final pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 100,
      );

      if (pickedFile != null) {
        final imageBytes = await pickedFile.readAsBytes();

        emit(CameraPictureTaken(
          imageBytes: imageBytes,
          corners: const [], // 🔹 empty for now
        ));
      } else {
        emit(CameraError("No image selected"));
      }
    } catch (e) {
      emit(CameraError("Error picking image: $e"));
    }
  }

  Future<void> _onToggleFlash(
      ToggleFlash event,
      Emitter<CameraState> emit,
      ) async {
    if (state is CameraReady) {
      final current = state as CameraReady;
      final newMode =
      current.flashMode == FlashMode.off ? FlashMode.torch : FlashMode.off;

      CameraService.instance.setFlashMode(newMode);
      emit(current.copyWith(flashMode: newMode));
    }
  }

  @override
  Future<void> close() {
    CameraService.instance.dispose();
    return super.close();
  }
}
