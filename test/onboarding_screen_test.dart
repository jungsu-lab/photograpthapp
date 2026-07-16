import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:framefit/features/onboarding/onboarding_screen.dart';

void main() {
  testWidgets('primary onboarding action starts photo import', (tester) async {
    var imported = false;
    var completed = false;

    await tester.pumpWidget(
      MaterialApp(
        home: OnboardingScreen(
          onImport: () async {
            imported = true;
          },
          onCompleted: () async {
            completed = true;
          },
          onCamera: () async {},
        ),
      ),
    );

    await tester.tap(find.byKey(const Key('onboardingPrimaryCta')));
    await tester.pump();

    expect(imported, isTrue);
    expect(completed, isFalse);
  });

  testWidgets('secondary onboarding action starts camera', (tester) async {
    var openedCamera = false;

    await tester.pumpWidget(
      MaterialApp(
        home: OnboardingScreen(
          onImport: () async {},
          onCompleted: () async {},
          onCamera: () async {
            openedCamera = true;
          },
        ),
      ),
    );

    await tester.tap(find.byKey(const Key('onboardingCameraCta')));
    await tester.pump();

    expect(openedCamera, isTrue);
  });

  testWidgets('onboarding remains scrollable on supported phone sizes', (
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
          child: MaterialApp(
            home: OnboardingScreen(
              onImport: () async {},
              onCompleted: () async {},
              onCamera: () async {},
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.byKey(const Key('onboardingPrimaryCta')), findsOneWidget);
      expect(find.byKey(const Key('onboardingCameraCta')), findsOneWidget);
      expect(tester.takeException(), isNull);
    }
  });
}
