import 'dart:async';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

import '../../core/router/app_routes.dart';
import '../../data/presets/preset_catalog.dart';
import '../../domain/models/composition_template.dart';
import '../../domain/models/photo_preset.dart';
import '../../domain/models/selected_photo.dart';
import '../../services/device_settings_service.dart';
import '../../services/device_pose_service.dart';
import '../../services/camera_permission_service.dart';
import '../../services/photo_input_service.dart';
import '../editor/editor_screen.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({
    super.key,
    this.template,
    this.initialPresetId,
    this.cameraPermissions,
  });

  final CompositionTemplate? template;
  final String? initialPresetId;
  final CameraPermissionService? cameraPermissions;

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen>
    with WidgetsBindingObserver {
  final _photoInput = PhotoInputService();
  final _deviceSettings = const PlatformDeviceSettingsService();
  final DevicePoseService _devicePose = const PlatformDevicePoseService();
  late final CameraPermissionService _cameraPermissions;
  CameraController? _controller;
  StreamSubscription<DevicePoseReading>? _poseSubscription;
  List<CameraDescription> _cameras = const [];
  bool _isInitializing = true;
  bool _isCapturing = false;
  String? _cameraError;
  bool _cameraPermissionLocked = false;
  int _initializationGeneration = 0;
  String _mode = '인물';
  FlashMode _flashMode = FlashMode.off;
  DevicePoseGuidance? _poseGuidance;

  static const _modes = ['인물', '셀카', '음식', '여행', '상품', '감성'];
  static const _initializationTimeout = Duration(seconds: 12);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _cameraPermissions =
        widget.cameraPermissions ?? const PlatformCameraPermissionService();
    _mode = widget.template?.name ?? _mode;
    _startPoseCoaching();
    _initializeCamera();
  }

  @override
  void dispose() {
    _initializationGeneration++;
    WidgetsBinding.instance.removeObserver(this);
    _poseSubscription?.cancel();
    _controller?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final controller = _controller;
    if (controller == null) return;
    if (state == AppLifecycleState.inactive) {
      _initializationGeneration++;
      controller.dispose();
      _controller = null;
    } else if (state == AppLifecycleState.resumed) {
      // Permission handling is awaited before controller creation. A live
      // surface alone needs to be recreated after the app returns.
      _initializeCamera();
    }
  }

  Future<void> _initializeCamera({CameraDescription? preferred}) async {
    final generation = ++_initializationGeneration;
    setState(() {
      _isInitializing = true;
      _cameraError = null;
      _cameraPermissionLocked = false;
    });
    CameraController? next;
    try {
      final permission = await _cameraPermissions.requestCamera();
      if (!_isCurrentInitialization(generation)) return;
      if (permission != CameraPermissionStatus.granted) {
        _showCameraPermissionError(permission);
        return;
      }
      _cameras = await availableCameras().timeout(_initializationTimeout);
      if (!_isCurrentInitialization(generation)) return;
      if (_cameras.isEmpty) {
        throw CameraException('no-camera', '사용 가능한 카메라가 없어요.');
      }
      final camera = preferred ?? _preferredCamera();
      next = CameraController(
        camera,
        ResolutionPreset.high,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );
      await next.initialize().timeout(_initializationTimeout);
      await _applyTemplateCameraSettings(next);
      final old = _controller;
      if (!_isCurrentInitialization(generation)) {
        await next.dispose();
        return;
      }
      setState(() => _controller = next);
      await old?.dispose();
    } on TimeoutException {
      await next?.dispose();
      if (_isCurrentInitialization(generation)) {
        setState(
          () => _cameraError =
              '카메라 응답이 늦어요. 다른 앱에서 카메라를 사용 중인지 확인한 뒤 다시 시도해 주세요.',
        );
      }
    } on CameraException catch (error) {
      await next?.dispose();
      if (_isCurrentInitialization(generation)) {
        setState(() {
          _cameraError = _cameraMessage(error);
          _cameraPermissionLocked =
              error.code == 'CameraAccessDeniedWithoutPrompt';
        });
      }
    } catch (_) {
      await next?.dispose();
      if (_isCurrentInitialization(generation)) {
        setState(() => _cameraError = '카메라를 시작하지 못했어요. 권한을 확인해 주세요.');
      }
    } finally {
      if (_isCurrentInitialization(generation)) {
        setState(() => _isInitializing = false);
      }
    }
  }

  bool _isCurrentInitialization(int generation) =>
      mounted && generation == _initializationGeneration;

  void _showCameraPermissionError(CameraPermissionStatus permission) {
    final locked =
        permission == CameraPermissionStatus.permanentlyDenied ||
        permission == CameraPermissionStatus.restricted;
    setState(() {
      _cameraPermissionLocked = locked;
      _cameraError = switch (permission) {
        CameraPermissionStatus.permanentlyDenied =>
          '카메라 권한이 꺼져 있어요. 설정에서 접근을 허용해 주세요.',
        CameraPermissionStatus.restricted => '이 기기에서는 카메라 접근이 제한되어 있어요.',
        CameraPermissionStatus.denied => '카메라 권한이 필요해요. 허용한 뒤 다시 시도해 주세요.',
        CameraPermissionStatus.granted => null,
      };
    });
  }

  CameraDescription _preferredCamera() {
    final template = widget.template;
    var candidates = _cameras;
    if (template?.cameraFacing == CameraFacingPreference.front) {
      candidates = candidates
          .where((item) => item.lensDirection == CameraLensDirection.front)
          .toList();
    } else if (template?.cameraFacing == CameraFacingPreference.back) {
      candidates = candidates
          .where((item) => item.lensDirection == CameraLensDirection.back)
          .toList();
    }
    if (candidates.isEmpty) candidates = _cameras;
    if (template?.lensPreference == LensPreference.ultraWide) {
      final ultraWide = candidates.where(
        (item) => item.lensType == CameraLensType.ultraWide,
      );
      if (ultraWide.isNotEmpty) return ultraWide.first;
    }
    return candidates.first;
  }

  Future<void> _applyTemplateCameraSettings(CameraController controller) async {
    final requestedMode = widget.template?.flashPreference == FlashPreference.on
        ? FlashMode.always
        : FlashMode.off;
    try {
      await controller.setFlashMode(requestedMode);
      _flashMode = requestedMode;
    } on CameraException {
      // Some lenses do not provide a flash. The capture flow remains usable.
      _flashMode = FlashMode.off;
    }
  }

  void _startPoseCoaching() {
    final target = widget.template?.devicePoseTarget;
    if (target == null ||
        !(widget.template?.capabilities.contains(CoachCapability.sensor) ??
            false)) {
      return;
    }
    _poseSubscription = _devicePose.readings.listen(
      (reading) {
        final guidance = guidanceForPose(
          reading,
          targetRollDegrees: target.targetRollDegrees,
          rollToleranceDegrees: target.rollToleranceDegrees,
          targetFlatnessDegrees: target.targetPitchDegrees,
          flatnessToleranceDegrees: target.pitchToleranceDegrees,
        );
        if (mounted) setState(() => _poseGuidance = guidance);
      },
      onError: (_) {
        if (mounted) {
          setState(
            () => _poseGuidance = const DevicePoseGuidance(
              message: '이 기기에서는 수평 안내를 사용할 수 없어요.',
              isAligned: false,
            ),
          );
        }
      },
    );
  }

  Future<void> _capture() async {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized || _isCapturing) {
      return;
    }
    setState(() => _isCapturing = true);
    try {
      final capture = await controller.takePicture();
      final bytes = await capture.readAsBytes();
      if (!mounted) return;
      await Navigator.pushNamed(
        context,
        AppRoutes.editor,
        arguments: EditorArgs(
          photo: SelectedPhoto(
            name: capture.name.isEmpty ? 'framefit-camera.jpg' : capture.name,
            bytes: bytes,
            source: PhotoSource.camera,
          ),
          initialPreset: _recommendedPreset,
        ),
      );
    } on CameraException catch (error) {
      if (mounted) _message(_cameraMessage(error));
    } catch (_) {
      if (mounted) _message('촬영한 사진을 열지 못했어요. 다시 시도해 주세요.');
    } finally {
      if (mounted) setState(() => _isCapturing = false);
    }
  }

  PhotoPreset? get _recommendedPreset {
    final linkedIds = widget.template?.linkedPresetIds;
    final presetId =
        widget.initialPresetId ??
        (linkedIds == null || linkedIds.isEmpty ? null : linkedIds.first);
    if (presetId == null) return null;
    for (final preset in presetCatalog) {
      if (preset.id == presetId) return preset;
    }
    return null;
  }

  Future<void> _openGallery() async {
    try {
      final photo = await _photoInput.pickFromGallery();
      if (!mounted || photo == null) return;
      await Navigator.pushNamed(
        context,
        AppRoutes.editor,
        arguments: EditorArgs(photo: photo),
      );
    } catch (error) {
      if (mounted) _message('사진을 열지 못했어요. $error');
    }
  }

  Future<void> _switchCamera() async {
    if (_cameras.length < 2) return;
    final current = _controller?.description;
    final next = _cameras.firstWhere(
      (camera) => camera.name != current?.name,
      orElse: () => _cameras.first,
    );
    await _initializeCamera(preferred: next);
  }

  Future<void> _toggleFlash() async {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) return;
    final nextMode = _flashMode == FlashMode.off
        ? FlashMode.always
        : FlashMode.off;
    try {
      await controller.setFlashMode(nextMode);
      if (mounted) setState(() => _flashMode = nextMode);
    } on CameraException {
      if (mounted) _message('현재 카메라에서는 플래시를 사용할 수 없어요.');
    }
  }

  Future<void> _openAppSettings() async {
    try {
      await _deviceSettings.openApplicationSettings();
    } catch (_) {
      if (mounted) {
        _message('설정 화면을 열지 못했어요. 기기 설정에서 FrameFit의 카메라 권한을 허용해 주세요.');
      }
    }
  }

  void _message(String message) => ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message)));

  String _cameraMessage(CameraException error) => switch (error.code) {
    'CameraAccessDenied' => '카메라 권한이 필요해요. 설정에서 카메라 접근을 허용해 주세요.',
    'CameraAccessDeniedWithoutPrompt' => '카메라 권한이 꺼져 있어요. 설정에서 접근을 허용해 주세요.',
    'CameraAccessRestricted' => '이 기기에서는 카메라 접근이 제한되어 있어요.',
    _ => '카메라를 열지 못했어요. 잠시 후 다시 시도해 주세요.',
  };

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: const Color(0xFF111111),
    body: SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 6, 8, 12),
            child: Row(
              children: [
                IconButton(
                  tooltip: '닫기',
                  onPressed: () => Navigator.maybePop(context),
                  icon: const Icon(Icons.close, color: Colors.white),
                ),
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        _mode,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        '촬영 가이드',
                        style: TextStyle(
                          color: Color(0xFFB7B7B7),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: '카메라 전환',
                  onPressed: _cameras.length > 1 ? _switchCamera : null,
                  icon: const Icon(
                    Icons.cameraswitch_outlined,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    _buildPreview(),
                    IgnorePointer(
                      child: _CompositionOverlay(template: widget.template),
                    ),
                    if (_poseGuidance != null)
                      Positioned(
                        top: 14,
                        left: 14,
                        right: 14,
                        child: _PoseCaption(guidance: _poseGuidance!),
                      ),
                    Positioned(
                      left: 14,
                      right: 14,
                      bottom: 14,
                      child: _GuideCaption(
                        mode: _mode,
                        template: widget.template,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (widget.template == null)
            SizedBox(
              height: 58,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 10,
                ),
                scrollDirection: Axis.horizontal,
                itemCount: _modes.length,
                separatorBuilder: (_, _) => const SizedBox(width: 20),
                itemBuilder: (context, index) {
                  final mode = _modes[index];
                  final selected = mode == _mode;
                  return GestureDetector(
                    onTap: () => setState(() => _mode = mode),
                    child: Text(
                      mode,
                      style: TextStyle(
                        color: selected
                            ? Colors.white
                            : const Color(0xFF9D9D9D),
                        fontWeight: selected
                            ? FontWeight.w800
                            : FontWeight.w500,
                      ),
                    ),
                  );
                },
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 10, 18, 6),
              child: Row(
                children: [
                  const Icon(
                    Icons.grid_view_rounded,
                    color: Color(0xFFF1D591),
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${widget.template!.name} 가이드 적용 중',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(28, 4, 28, 18),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  tooltip: '갤러리에서 사진 선택',
                  onPressed: _openGallery,
                  icon: const Icon(
                    Icons.photo_library_outlined,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                SizedBox(
                  width: 76,
                  height: 76,
                  child: IconButton(
                    key: const Key('captureButton'),
                    tooltip: '촬영',
                    onPressed: _isCapturing || _isInitializing
                        ? null
                        : _capture,
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      shape: const CircleBorder(),
                    ),
                    icon: _isCapturing
                        ? const CircularProgressIndicator()
                        : const Icon(Icons.camera_alt_outlined, size: 32),
                  ),
                ),
                IconButton(
                  tooltip: _flashMode == FlashMode.off ? '플래시 켜기' : '플래시 끄기',
                  onPressed: _toggleFlash,
                  icon: Icon(
                    _flashMode == FlashMode.off
                        ? Icons.flash_off_outlined
                        : Icons.flash_on_rounded,
                    color: _flashMode == FlashMode.off
                        ? Colors.white
                        : const Color(0xFFF1D591),
                    size: 28,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );

  Widget _buildPreview() {
    final controller = _controller;
    if (_cameraError != null) {
      return _CameraState(
        icon: Icons.no_photography_outlined,
        message: _cameraError!,
        actionLabel: _cameraPermissionLocked ? '설정 열기' : '다시 시도',
        onAction: _cameraPermissionLocked
            ? _openAppSettings
            : _initializeCamera,
      );
    }
    if (_isInitializing ||
        controller == null ||
        !controller.value.isInitialized) {
      return const _CameraState(
        icon: Icons.camera_alt_outlined,
        message: '카메라를 준비하는 중이에요.',
      );
    }
    return CameraPreview(controller);
  }
}

class _CompositionOverlay extends StatelessWidget {
  const _CompositionOverlay({this.template});

  final CompositionTemplate? template;

  @override
  Widget build(BuildContext context) =>
      CustomPaint(painter: _GridPainter(template?.overlay));
}

class _GridPainter extends CustomPainter {
  const _GridPainter(this.overlay);

  final OverlaySpec? overlay;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: .32)
      ..strokeWidth = 1;
    final type = overlay?.type ?? CompositionOverlayType.thirds;
    if (type == CompositionOverlayType.thirds) {
      for (var i = 1; i <= 2; i++) {
        canvas.drawLine(
          Offset(size.width * i / 3, 0),
          Offset(size.width * i / 3, size.height),
          paint,
        );
        canvas.drawLine(
          Offset(0, size.height * i / 3),
          Offset(size.width, size.height * i / 3),
          paint,
        );
      }
    } else if (type == CompositionOverlayType.centre ||
        type == CompositionOverlayType.reflection) {
      canvas.drawLine(
        Offset(size.width / 2, 0),
        Offset(size.width / 2, size.height),
        paint,
      );
      canvas.drawLine(
        Offset(0, size.height / 2),
        Offset(size.width, size.height / 2),
        paint,
      );
      canvas.drawCircle(
        Offset(size.width / 2, size.height / 2),
        size.shortestSide * .18,
        paint..style = PaintingStyle.stroke,
      );
    } else if (type == CompositionOverlayType.topDown) {
      canvas.drawLine(
        Offset(size.width / 2, 0),
        Offset(size.width / 2, size.height),
        paint,
      );
      canvas.drawLine(
        Offset(0, size.height / 2),
        Offset(size.width, size.height / 2),
        paint,
      );
      canvas.drawRect(
        Rect.fromCenter(
          center: Offset(size.width / 2, size.height / 2),
          width: size.width * .58,
          height: size.height * .42,
        ),
        paint..style = PaintingStyle.stroke,
      );
    } else if (type == CompositionOverlayType.leadingLines) {
      for (final line in overlay?.lines ?? const <NormalizedLine>[]) {
        canvas.drawLine(
          Offset(line.start.x * size.width, line.start.y * size.height),
          Offset(line.end.x * size.width, line.end.y * size.height),
          paint..color = const Color(0xFFF1D591).withValues(alpha: .72),
        );
      }
    } else if (type == CompositionOverlayType.frame) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(
            size.width * .15,
            size.height * .16,
            size.width * .7,
            size.height * .68,
          ),
          const Radius.circular(12),
        ),
        paint..style = PaintingStyle.stroke,
      );
    } else {
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(size.width / 2, size.height * .52),
          width: size.width * .46,
          height: size.height * .72,
        ),
        paint..style = PaintingStyle.stroke,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _GridPainter oldDelegate) =>
      oldDelegate.overlay != overlay;
}

class _GuideCaption extends StatelessWidget {
  const _GuideCaption({required this.mode, this.template});
  final String mode;
  final CompositionTemplate? template;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      color: Colors.black54,
      borderRadius: BorderRadius.circular(12),
    ),
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Text(
        _copy,
        style: const TextStyle(color: Colors.white, fontSize: 14, height: 1.3),
      ),
    ),
  );

  String get _copy {
    final copy = template?.coachingCopy;
    if (copy != null && copy.isNotEmpty) return copy.first;
    return switch (mode) {
      '인물' => '얼굴을 가운데보다 살짝 위에 두고, 배경이 단순한 쪽을 찾아보세요.',
      '셀카' => '카메라를 눈높이보다 조금 높게 두면 자연스럽게 보여요.',
      '음식' => '접시 가장자리가 화면에 잘리지 않게 한 걸음 뒤로 가보세요.',
      '여행' => '수평선을 격자에 맞추고, 하늘 여백을 남겨보세요.',
      '상품' => '빛이 고르게 닿는 곳에서 제품 주변 여백을 정리해보세요.',
      _ => '주인공을 한쪽 격자선에 두고 주변 여백을 충분히 남겨보세요.',
    };
  }
}

class _PoseCaption extends StatelessWidget {
  const _PoseCaption({required this.guidance});

  final DevicePoseGuidance guidance;

  @override
  Widget build(BuildContext context) => Align(
    alignment: Alignment.topCenter,
    child: DecoratedBox(
      decoration: BoxDecoration(
        color: guidance.isAligned
            ? const Color(0xCC23513C)
            : const Color(0xCC111111),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: guidance.isAligned
              ? const Color(0xFF9DE0B4)
              : const Color(0xFF777777),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              guidance.isAligned
                  ? Icons.check_circle_outline_rounded
                  : Icons.screen_rotation_alt_outlined,
              size: 16,
              color: guidance.isAligned
                  ? const Color(0xFFD2F5DD)
                  : const Color(0xFFF3F3F3),
            ),
            const SizedBox(width: 6),
            Text(
              guidance.message,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class _CameraState extends StatelessWidget {
  const _CameraState({
    required this.icon,
    required this.message,
    this.actionLabel,
    this.onAction,
  });
  final IconData icon;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) => ColoredBox(
    color: const Color(0xFF252525),
    child: Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 34),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white),
            ),
            if (actionLabel != null) ...[
              const SizedBox(height: 10),
              TextButton(onPressed: onAction, child: Text(actionLabel!)),
            ],
          ],
        ),
      ),
    ),
  );
}
