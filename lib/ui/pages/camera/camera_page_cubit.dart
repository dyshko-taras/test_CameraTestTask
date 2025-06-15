import 'dart:developer' show log;
import 'dart:io' show File;

import 'package:camera/camera.dart';
import 'package:camera_test_task/ui/pages/camera/camera_page_state.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class CameraCubit extends Cubit<CameraState> {
  CameraController? cameraController;
  List<CameraDescription> cameras = [];
  File? overlay;
  final ImagePicker _picker = ImagePicker();

  static const platform = MethodChannel(
    'com.test.test.camera_test_task/media_store',
  );

  CameraCubit() : super(CameraState.initial());

  Future<void> initCamera() async {
    try {
      final status = await Permission.camera.request();
      if (!status.isGranted) {
        emit(CameraState.error('Camera permission denied'));
        return;
      }

      cameras = await availableCameras();
      if (cameras.isEmpty) {
        emit(CameraState.error('No cameras available'));
        return;
      }

      final backCamera = cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );

      cameraController = CameraController(backCamera, ResolutionPreset.high);
      await cameraController!.initialize();
      emit(CameraState.ready(controller: cameraController!, overlay: overlay));
    } catch (e) {
      emit(CameraState.error('Camera initialization failed: $e'));
    }
  }

  Future<void> switchCamera() async {
    if (cameras.length <= 1 || cameraController == null) return;

    try {
      final current = cameraController!.description;
      final currentIndex = cameras.indexOf(current);
      final nextIndex = (currentIndex + 1) % cameras.length;
      final nextCamera = cameras[nextIndex];

      await cameraController!.dispose();

      cameraController = CameraController(nextCamera, ResolutionPreset.high);
      await cameraController!.initialize();
      emit(state.copyWith(controller: cameraController));
    } catch (e) {
      emit(CameraState.error('Camera switch failed: $e'));
    }
  }

  Future<void> pickOverlay() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        overlay = File(pickedFile.path);
        emit(state.copyWith(overlay: overlay));
      }
    } catch (e) {
      emit(CameraState.error('Pick overlay failed: $e'));
    }
  }

  Future<void> takePicture() async {
    if (cameraController == null || !cameraController!.value.isInitialized) {
      return;
    }

    try {
      final xfile = await cameraController!.takePicture();

      final success = await _saveImageToGallery(xfile.path);
      if (success) {
        emit(state.copyWith(lastCaptured: xfile.path));
      } else {
        emit(CameraState.error('Failed to save image to gallery'));
      }
    } catch (e) {
      emit(CameraState.error('Take picture failed: $e'));
    }
  }

  Future<void> toggleRecording() async {
    if (cameraController == null || !cameraController!.value.isInitialized) {
      return;
    }

    try {
      if (cameraController!.value.isRecordingVideo) {
        final file = await cameraController!.stopVideoRecording();

        final success = await _saveVideoToGallery(file.path);
        if (success) {
          emit(
            state.copyWith(status: CamStatus.ready, lastRecorded: file.path),
          );
        } else {
          emit(CameraState.error('Failed to save video to gallery'));
        }
      } else {
        await cameraController!.startVideoRecording();
        emit(state.copyWith(status: CamStatus.recording));
      }
    } catch (e) {
      emit(CameraState.error('Video recording failed: $e'));
    }
  }

  Future<bool> _saveImageToGallery(String imagePath) async {
    try {
      final result = await platform.invokeMethod('saveImage', {
        'path': imagePath,
        'displayName': 'IMG_${DateTime.now().millisecondsSinceEpoch}.jpg',
      });
      return result == true;
    } on PlatformException catch (e) {
      log('Failed to save image: ${e.message}');
      return false;
    }
  }

  Future<bool> _saveVideoToGallery(String videoPath) async {
    try {
      final result = await platform.invokeMethod('saveVideo', {
        'path': videoPath,
        'displayName': 'VID_${DateTime.now().millisecondsSinceEpoch}.mp4',
      });
      return result == true;
    } on PlatformException catch (e) {
      log('Failed to save video: ${e.message}');
      return false;
    }
  }

  @override
  Future<void> close() {
    cameraController?.dispose();
    return super.close();
  }
}
