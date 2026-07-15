import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:framefit/features/home/home_screen.dart';

void main() {
  testWidgets('home makes photo import the primary action', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(const MaterialApp(home: HomeScreen()));

    expect(find.text('사진 불러오기'), findsOneWidget);
    expect(find.byKey(const Key('importPhotoButton')), findsOneWidget);
    expect(find.text('카메라로 촬영'), findsOneWidget);
    expect(find.text('바로 써보기'), findsOneWidget);
    expect(find.text('최근 작업'), findsOneWidget);
    expect(find.bySemanticsLabel('자연 보정 프리셋 적용 예시'), findsOneWidget);
  });

  testWidgets('home remains usable on supported small and large screens', (
    tester,
  ) async {
    final sizes = <Size>[
      const Size(360, 800),
      const Size(390, 844),
      const Size(412, 915),
    ];
    addTearDown(() => tester.binding.setSurfaceSize(null));

    for (final size in sizes) {
      await tester.binding.setSurfaceSize(size);
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(textScaler: TextScaler.linear(1.3)),
          child: const MaterialApp(home: HomeScreen()),
        ),
      );
      await tester.pump();

      expect(find.byKey(const Key('importPhotoButton')), findsOneWidget);
      expect(find.text('카메라로 촬영'), findsOneWidget);
      expect(tester.takeException(), isNull);
    }
  });
}
