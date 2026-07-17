import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:framefit/features/onboarding/onboarding_screen.dart';

void main() {
  Future<void> pumpOnboarding(
    WidgetTester tester,
    Size size, {
    double textScale = 1,
  }) async {
    await tester.binding.setSurfaceSize(size);
    await tester.pumpWidget(
      MediaQuery(
        data: MediaQueryData(textScaler: TextScaler.linear(textScale)),
        child: MaterialApp(
          home: OnboardingScreen(
            onImport: () async {},
            onCompleted: () async {},
            onCamera: () async {},
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('onboarding matches the compact accessible visual baseline', (
    tester,
  ) async {
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await pumpOnboarding(tester, const Size(360, 800), textScale: 1.3);

    await expectLater(
      find.byType(OnboardingScreen),
      matchesGoldenFile('goldens/onboarding_360x800_text130.png'),
    );
  });

  testWidgets('onboarding matches the large phone visual baseline', (
    tester,
  ) async {
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await pumpOnboarding(tester, const Size(412, 915));

    await expectLater(
      find.byType(OnboardingScreen),
      matchesGoldenFile('goldens/onboarding_412x915.png'),
    );
  });
}
