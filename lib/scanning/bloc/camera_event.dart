part of 'camera_bloc.dart';

abstract class CameraEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class InitializeCamera extends CameraEvent {}

class TakePicture extends CameraEvent {}

class PickFromGallery extends CameraEvent {}

class ToggleFlash extends CameraEvent {}
