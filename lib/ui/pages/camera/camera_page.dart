import 'package:camera/camera.dart';
import 'package:camera_test_task/ui/pages/camera/camera_page_cubit.dart';
import 'package:camera_test_task/ui/pages/camera/camera_page_state.dart';
import 'package:camera_test_task/ui/utils/widget_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CameraPage extends StatelessWidget {
  const CameraPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CameraCubit()..initCamera(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Camera test task',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        body: BlocBuilder<CameraCubit, CameraState>(
          builder: (context, state) {
            if (state.status == CamStatus.error) {
              return Center(child: Text(state.errorMessage!));
            }
            if (state.status == CamStatus.initial ||
                state.controller == null ||
                !state.controller!.value.isInitialized) {
              return const Center(child: CircularProgressIndicator());
            }
            return Stack(
              children: [
                CameraPreview(state.controller!),
                if (state.overlay != null)
                  Opacity(
                    opacity: 0.8,
                    child: Image.file(
                      state.overlay!,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                    ),
                  ),
                Positioned(
                  bottom: 20,
                  left: 20,
                  right: 20,
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.cameraswitch),
                        color: Colors.white,
                        iconSize: 32,
                        onPressed:
                            () => context.read<CameraCubit>().switchCamera(),
                      ),
                      spacerHorizontal(20),
                      IconButton(
                        icon: const Icon(Icons.photo_library),
                        color: Colors.white,
                        iconSize: 32,
                        onPressed:
                            () => context.read<CameraCubit>().pickOverlay(),
                      ),
                      spacerAdaptive(),
                      IconButton(
                        icon: Icon(
                          state.controller!.value.isRecordingVideo
                              ? Icons.stop
                              : Icons.videocam,
                        ),
                        color: Colors.red,
                        iconSize: 48,
                        onPressed:
                            () => context.read<CameraCubit>().toggleRecording(),
                      ),
                      spacerAdaptive(),
                      IconButton(
                        icon: const Icon(Icons.camera_alt),
                        color: Colors.white,
                        iconSize: 32,
                        onPressed:
                            () => context.read<CameraCubit>().takePicture(),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
