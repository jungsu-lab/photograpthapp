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
        ),
      ),
    );

    await tester.tap(find.byKey(const Key('onboardingPrimaryCta')));
    await tester.pump();

    expect(imported, isTrue);
    expect(completed, isFalse);
  });
}
