import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

import '../../core/router/app_routes.dart';
import '../../domain/models/selected_photo.dart';
import '../../services/photo_input_service.dart';
import '../../services/device_settings_service.dart';
import '../editor/editor_screen.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen>
    with WidgetsBindingObserver {
  final _photoInput = PhotoInputService();
  final _deviceSettings = const PlatformDeviceSettingsService();
  CameraController? _controller;
  List<CameraDescription> _cameras = const [];
  bool _isInitializing = true;
  bool _isCapturing = false;
  String? _cameraError;
  bool _cameraPermissionLocked = false;
  String _mode = '인물';

  static const _modes = ['인물', '셀카', '음식', '여행', '상품', '감성'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeCamera();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final controller = _controller;
    if (controller == null) return;
    if (state == AppLifecycleState.inactive) {
      controller.dispose();
      _controller = null;
    } else if (state == AppLifecycleState.resumed) {
      _initializeCamera();
    }
  }

  Future<void> _initializeCamera({CameraDescription? preferred}) async {
    setState(() {
      _isInitializing = true;
      _cameraError = null;
      _cameraPermissionLocked = false;
    });
    try {
      _cameras = await availableCameras();
      if (_cameras.isEmpty) {
        throw CameraException('no-camera', '사용 가능한 카메라가 없어요.');
      }
      final camera =
          preferred ??
          _cameras.firstWhere(
            (item) => item.lensDirection == CameraLensDirection.back,
            orElse: () => _cameras.first,
          );
      final next = CameraController(
        camera,
        ResolutionPreset.high,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );
      await next.initialize();
      final old = _controller;
      if (!mounted) {
        await next.dispose();
        return;
      }
      setState(() => _controller = next);
      await old?.dispose();
    } on CameraException catch (error) {
      if (mounted) {
        setState(() {
          _cameraError = _cameraMessage(error);
          _cameraPermissionLocked =
              error.code == 'CameraAccessDeniedWithoutPrompt';
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _cameraError = '카메라를 시작하지 못했어요. 권한을 확인해 주세요.');
      }
    } finally {
      if (mounted) {
        setState(() => _isInitializing = false);
      }
    }
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
                    const IgnorePointer(child: _CompositionOverlay()),
                    Positioned(
                      left: 14,
                      right: 14,
                      bottom: 14,
                      child: _GuideCaption(mode: _mode),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(
            height: 58,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
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
                      color: selected ? Colors.white : const Color(0xFF9D9D9D),
                      fontWeight: selected ? FontWeight.w800 : FontWeight.w500,
                    ),
                  ),
                );
              },
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
                const SizedBox(width: 48),
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
  const _CompositionOverlay();

  @override
  Widget build(BuildContext context) => CustomPaint(painter: _GridPainter());
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: .32)
      ..strokeWidth = 1;
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
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _GuideCaption extends StatelessWidget {
  const _GuideCaption({required this.mode});
  final String mode;

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

  String get _copy => switch (mode) {
    '인물' => '얼굴을 가운데보다 살짝 위에 두고, 배경이 단순한 쪽을 찾아보세요.',
    '셀카' => '카메라를 눈높이보다 조금 높게 두면 자연스럽게 보여요.',
    '음식' => '접시 가장자리가 화면에 잘리지 않게 한 걸음 뒤로 가보세요.',
    '여행' => '수평선을 격자에 맞추고, 하늘 여백을 남겨보세요.',
    '상품' => '빛이 고르게 닿는 곳에서 제품 주변 여백을 정리해보세요.',
    _ => '주인공을 한쪽 격자선에 두고 주변 여백을 충분히 남겨보세요.',
  };
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
