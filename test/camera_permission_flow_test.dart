import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:framefit/features/camera/camera_screen.dart';
import 'package:framefit/services/camera_permission_service.dart';

class _FixedCameraPermissions implements CameraPermissionService {
  const _FixedCameraPermissions(this.status);

  final CameraPermissionStatus status;

  @override
  Future<CameraPermissionStatus> requestCamera() async => status;
}

void main() {
  testWidgets('permanently denied camera permission offers settings', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: CameraScreen(
          cameraPermissions: _FixedCameraPermissions(
            CameraPermissionStatus.permanentlyDenied,
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('카메라 권한이 꺼져 있어요. 설정에서 접근을 허용해 주세요.'), findsOneWidget);
    expect(find.text('설정 열기'), findsOneWidget);
  });

  testWidgets('ordinary camera denial can be retried', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: CameraScreen(
          cameraPermissions: _FixedCameraPermissions(
            CameraPermissionStatus.denied,
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('카메라 권한이 필요해요. 허용한 뒤 다시 시도해 주세요.'), findsOneWidget);
    expect(find.text('다시 시도'), findsOneWidget);
  });
}
