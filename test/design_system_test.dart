import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:framefit/core/theme/app_theme.dart';

void main() {
  test('design tokens keep primary controls touch-safe', () {
    expect(AppMetrics.buttonHeight, greaterThanOrEqualTo(44));
    expect(AppMetrics.bottomNavHeight, greaterThanOrEqualTo(48));
    expect(AppTheme.light.filledButtonTheme.style, isNotNull);
    expect(AppTheme.light.outlinedButtonTheme.style, isNotNull);
  });

  testWidgets('primary and secondary buttons expose readable labels', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: Column(
            children: [
              FilledButton(onPressed: () {}, child: const Text('사진 불러오기')),
              OutlinedButton(onPressed: () {}, child: const Text('카메라로 촬영')),
            ],
          ),
        ),
      ),
    );

    expect(find.text('사진 불러오기'), findsOneWidget);
    expect(find.text('카메라로 촬영'), findsOneWidget);
    expect(
      tester.getSize(find.byType(FilledButton)).height,
      greaterThanOrEqualTo(44),
    );
  });
}
