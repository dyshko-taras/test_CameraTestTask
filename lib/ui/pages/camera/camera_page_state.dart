import 'dart:io';
import 'package:camera/camera.dart';

enum CamStatus { initial, ready, recording, error }

class CameraState {
  final CamStatus status;
  final CameraController? controller;
  final File? overlay;
  final String? errorMessage;
  final String? lastCaptured;
  final String? lastRecorded;

  const CameraState({
    required this.status,
    this.controller,
    this.overlay,
    this.errorMessage,
    this.lastCaptured,
    this.lastRecorded,
  });

  factory CameraState.initial() => const CameraState(status: CamStatus.initial);

  factory CameraState.error(String msg) =>
      CameraState(status: CamStatus.error, errorMessage: msg);

  factory CameraState.ready({
    required CameraController controller,
    File? overlay,
  }) => CameraState(
    status: CamStatus.ready,
    controller: controller,
    overlay: overlay,
  );

  CameraState copyWith({
    CamStatus? status,
    CameraController? controller,
    File? overlay,
    String? errorMessage,
    String? lastCaptured,
    String? lastRecorded,
  }) {
    return CameraState(
      status: status ?? this.status,
      controller: controller ?? this.controller,
      overlay: overlay ?? this.overlay,
      errorMessage: errorMessage ?? this.errorMessage,
      lastCaptured: lastCaptured ?? this.lastCaptured,
      lastRecorded: lastRecorded ?? this.lastRecorded,
    );
  }
}
