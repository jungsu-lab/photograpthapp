import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:framefit/domain/models/selected_photo.dart';
import 'package:framefit/data/presets/preset_catalog.dart';
import 'package:framefit/features/editor/editor_screen.dart';
import 'package:framefit/services/photo_processor.dart';

class _ImmediatePhotoProcessor extends PhotoProcessor {
  const _ImmediatePhotoProcessor();

  @override
  Future<Uint8List> render(PhotoProcessRequest request) async =>
      request.sourceBytes;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Uint8List sampleJpeg() {
    final image = img.Image(width: 24, height: 16);
    image.clear(img.ColorRgb8(124, 148, 170));
    return Uint8List.fromList(img.encodeJpg(image));
  }

  testWidgets('editor presents explicit export options before rendering', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    await tester.pumpWidget(
      MaterialApp(
        home: EditorScreen(
          processor: const _ImmediatePhotoProcessor(),
          args: EditorArgs(
            photo: SelectedPhoto(
              name: 'sample.jpg',
              bytes: sampleJpeg(),
              source: PhotoSource.gallery,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('exportButton')));
    await tester.pumpAndSettle();

    expect(find.text('내보내기 설정'), findsOneWidget);
    expect(find.text('원본 해상도'), findsOneWidget);
    expect(find.text('긴 변 2048px'), findsOneWidget);
    expect(find.text('JPEG 품질 95'), findsOneWidget);
    expect(find.text('위치정보와 촬영 메타데이터는 항상 제거됩니다.'), findsOneWidget);

    await tester.tap(find.text('PNG'));
    await tester.pump();

    expect(find.text('JPEG 품질 95'), findsNothing);
  });

  testWidgets('editor reset returns the applied edit controls to original', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    await tester.pumpWidget(
      MaterialApp(
        home: EditorScreen(
          processor: const _ImmediatePhotoProcessor(),
          args: EditorArgs(
            photo: SelectedPhoto(
              name: 'sample.jpg',
              bytes: sampleJpeg(),
              source: PhotoSource.gallery,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('자연 보정'));
    await tester.pumpAndSettle();
    expect(find.text('자연 보정'), findsWidgets);

    await tester.tap(find.text('초기화'));
    await tester.pumpAndSettle();
    expect(find.text('원본'), findsWidgets);
  });

  testWidgets('editor undo and redo restore a selected preset', (tester) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    await tester.pumpWidget(
      MaterialApp(
        home: EditorScreen(
          processor: const _ImmediatePhotoProcessor(),
          args: EditorArgs(
            photo: SelectedPhoto(
              name: 'sample.jpg',
              bytes: sampleJpeg(),
              source: PhotoSource.gallery,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final preset = presetCatalog.first;
    await tester.tap(find.text(preset.name).last);
    await tester.pumpAndSettle();
    expect(find.text(preset.name), findsWidgets);
    expect(
      tester.widget<IconButton>(find.byKey(const Key('undoButton'))).onPressed,
      isNotNull,
    );

    await tester.tap(find.byKey(const Key('undoButton')));
    await tester.pumpAndSettle();
    expect(
      tester.widget<IconButton>(find.byKey(const Key('undoButton'))).onPressed,
      isNull,
    );
    expect(
      tester.widget<IconButton>(find.byKey(const Key('redoButton'))).onPressed,
      isNotNull,
    );

    await tester.tap(find.byKey(const Key('redoButton')));
    await tester.pumpAndSettle();
    expect(find.text(preset.name), findsWidgets);
    expect(
      tester.widget<IconButton>(find.byKey(const Key('undoButton'))).onPressed,
      isNotNull,
    );
    expect(
      tester.widget<IconButton>(find.byKey(const Key('redoButton'))).onPressed,
      isNull,
    );
  });

  testWidgets('advanced adjustment can reset one changed control', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    await tester.pumpWidget(
      MaterialApp(
        home: EditorScreen(
          processor: const _ImmediatePhotoProcessor(),
          args: EditorArgs(
            photo: SelectedPhoto(
              name: 'sample.jpg',
              bytes: sampleJpeg(),
              source: PhotoSource.gallery,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('고급 보정'));
    await tester.pumpAndSettle();
    await tester.drag(find.byType(Slider).first, const Offset(40, 0));
    await tester.pumpAndSettle();

    final reset = find.byKey(const Key('adjustReset-0'));
    expect(tester.widget<IconButton>(reset).onPressed, isNotNull);
    await tester.tap(reset);
    await tester.pumpAndSettle();
    expect(tester.widget<IconButton>(reset).onPressed, isNull);
  });
}
