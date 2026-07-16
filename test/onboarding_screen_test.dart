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
}
