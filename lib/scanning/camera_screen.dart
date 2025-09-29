import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'bloc/camera_bloc.dart';
import 'crop_screen.dart';

class CameraScreen extends StatelessWidget {
  const CameraScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CameraBloc()..add(InitializeCamera()),
      child: BlocConsumer<CameraBloc, CameraState>(
        listener: (context, state) {
          if (state is CameraPictureTaken) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => CropScreen(
                  imageBytes: state.imageBytes,
                ),
              ),
            ).then((_) {
              context.read<CameraBloc>().add(InitializeCamera());
            });
          } else if (state is CameraError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          if (state is CameraLoading) {
            return const Scaffold(
              backgroundColor: Colors.black,
              body: Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            );
          }

          if (state is CameraReady) {
            return Scaffold(
              backgroundColor: Colors.black,
              body: Stack(
                children: [
                  // Camera Preview
                  Positioned.fill(
                    child: FittedBox(
                      fit: BoxFit.cover,
                      child: SizedBox(
                        width: state.controller.value.previewSize!.height,
                        height: state.controller.value.previewSize!.width,
                        child: CameraPreview(state.controller),
                      ),
                    ),
                  ),

                  // Back Button
                  Positioned(
                    top: 50,
                    left: 20,
                    child: IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                  ),

                  // Controls
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: Container(
                      height: 140,
                      color: Colors.black.withOpacity(0.6),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 30,
                        vertical: 10,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          IconButton(
                            onPressed: () => context.read<CameraBloc>().add(
                              ToggleFlash(),
                            ),
                            icon: Icon(
                              state.flashMode == FlashMode.off
                                  ? Icons.flash_off
                                  : Icons.flash_on,
                              color: Colors.white,
                              size: 30,
                            ),
                          ),
                          GestureDetector(
                            onTap: () => context.read<CameraBloc>().add(
                              TakePicture(),
                            ),
                            child: Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 3,
                                ),
                              ),
                              child: const Icon(
                                Icons.camera_alt,
                                size: 40,
                                color: Colors.black,
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: () => context.read<CameraBloc>().add(
                              PickFromGallery(),
                            ),
                            icon: const Icon(
                              Icons.photo_library,
                              color: Colors.white,
                              size: 30,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          return const SizedBox();
        },
      ),
    );
  }
}
