part of 'camera_bloc.dart';

abstract class CameraState extends Equatable {
  @override
  List<Object?> get props => [];
}

class CameraInitial extends CameraState {}

class CameraLoading extends CameraState {}

class CameraReady extends CameraState {
  final CameraController controller;
  final FlashMode flashMode;

  CameraReady({required this.controller, required this.flashMode});

  CameraReady copyWith({CameraController? controller, FlashMode? flashMode}) {
    return CameraReady(
      controller: controller ?? this.controller,
      flashMode: flashMode ?? this.flashMode,
    );
  }

  @override
  List<Object?> get props => [controller, flashMode];
}

class CameraPictureTaken extends CameraState {
  final Uint8List imageBytes;
  final List<Offset> corners;

  CameraPictureTaken({required this.imageBytes, required this.corners});

  @override
  List<Object?> get props => [imageBytes, corners];
}

class CameraError extends CameraState {
  final String message;

  CameraError(this.message);

  @override
  List<Object?> get props => [message];
}
