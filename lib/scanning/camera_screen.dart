import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:smart_scan_flutter/utils/route.dart';
import './bloc/camera_bloc.dart';
import './bloc/camera_state.dart';
import './bloc/camera_event.dart';

class CameraScreen extends StatelessWidget {
  final bool isFirstPage;

  const CameraScreen({super.key, this.isFirstPage = true});

  // Helper method for navigation after capture/pick
  Future<Object?> _navigateToPreview(
    BuildContext context,
    String imagePath,
  ) async {
    final result = await Navigator.pushNamed(
      context,
      ROUTE_IMAGE_PREVIEW,
      arguments: {"imagePath": imagePath, "isFirstPage": isFirstPage},
    );

    return result;
  }

  Future<void> _pickFromGallery(BuildContext context) async {
    final ImagePicker picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final result = await _navigateToPreview(context, pickedFile.path);

      final isSubsequentPage = !isFirstPage;

      if (isSubsequentPage && context.mounted && result != null) {
        Navigator.pop(context, result);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // 1. Provide the Cubit at the top of the widget tree
    return BlocProvider(
      create: (_) => CameraBloc(),
      child: BlocBuilder<CameraBloc, CameraState>(
        builder: (context, state) {
          // 2. Handle state rendering
          if (state is CameraLoading) {
            return const Scaffold(
              backgroundColor: Colors.black,
              body: Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            );
          }

          if (state is CameraFailure) {
            return Scaffold(
              appBar: AppBar(title: Text("Camera Error")),
              body: Center(
                child: Text(
                  state.error,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            );
          }

          if (state is CameraReady) {
            return _CameraReadyView(
              controller: state.controller,
              isFlashOn: state.isFlashOn,
              navigateToPreview: _navigateToPreview,
              pickFromGallery: _pickFromGallery,
              isFirstPage: isFirstPage,
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}

// 3. Separate widget for the CameraReady UI
class _CameraReadyView extends StatelessWidget {
  final CameraController controller;
  final bool isFlashOn;
  final Function(BuildContext, String) navigateToPreview;
  final Function(BuildContext) pickFromGallery;
  final bool isFirstPage;

  const _CameraReadyView({
    required this.controller,
    required this.isFlashOn,
    required this.navigateToPreview,
    required this.pickFromGallery,
    required this.isFirstPage,
  });

  @override
  Widget build(BuildContext context) {
    final Size previewSize = controller.value.previewSize!;

    final cameraBloc = context.read<CameraBloc>();

    return Scaffold(
      body: Stack(
        children: [
          // Full-screen camera preview
          Positioned.fill(
            child: FittedBox(
              fit: BoxFit.cover,
              child: SizedBox(
                width: previewSize.height,
                height: previewSize.width,
                child: CameraPreview(controller),
              ),
            ),
          ),

          // Translucent bottom bar
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 32),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.4),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: SafeArea(
                top: false,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    // Flash Toggle Button
                    IconButton(
                      onPressed: () => cameraBloc.add(CameraFlashToggled()),
                      icon: Icon(
                        isFlashOn ? Icons.flash_on : Icons.flash_off,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),

                    // Capture Button
                    GestureDetector(
                      onTap: () async {
                        final path = await cameraBloc.captureImage();
                        if (path != null && context.mounted) {
                          final result = await navigateToPreview(context, path);

                          final isSubsequentPage = !isFirstPage;

                          if (isSubsequentPage &&
                              context.mounted &&
                              result != null) {
                            Navigator.pop(context, result);
                          }
                        }
                      },
                      child: Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 4),
                        ),
                      ),
                    ),

                    // Gallery Button
                    IconButton(
                      onPressed: () => pickFromGallery(context),
                      icon: const Icon(
                        Icons.photo_library,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
