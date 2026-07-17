import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:framefit/features/shell/framefit_shell.dart';
import 'package:framefit/services/preset_preferences.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('shell exposes home, shoot, and edit destinations', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    await tester.pumpWidget(const MaterialApp(home: FrameFitShell()));

    expect(find.text('홈'), findsOneWidget);
    expect(find.text('촬영'), findsOneWidget);
    expect(find.text('편집'), findsOneWidget);
    expect(find.text('사진 불러오기'), findsOneWidget);

    await tester.tap(find.text('촬영'));
    await tester.pumpAndSettle();
    expect(find.text('원하는 사진부터 고르세요.'), findsOneWidget);
    expect(find.text('빠른 촬영'), findsOneWidget);

    await tester.tap(find.text('편집'));
    await tester.pumpAndSettle();
    expect(find.text('사진에 맞는 분위기를 고르세요.'), findsOneWidget);
  });

  testWidgets('returning home refreshes recently used presets', (tester) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    await tester.pumpWidget(const MaterialApp(home: FrameFitShell()));
    await tester.pumpAndSettle();

    expect(find.text('도쿄 네온'), findsNothing);
    await tester.tap(find.text('촬영'));
    await tester.pumpAndSettle();
    await PresetPreferences().recordUse('tokyo-neon');
    expect(await PresetPreferences().recentIds(), contains('tokyo-neon'));

    await tester.tap(find.text('홈'));
    await tester.pumpAndSettle();
    await tester.drag(
      find.byKey(const Key('homeScrollView')),
      const Offset(0, -700),
    );
    await tester.pumpAndSettle();

    expect(
      find.descendant(
        of: find.byType(ActionChip),
        matching: find.text('도쿄 네온'),
      ),
      findsOneWidget,
    );
  });
}
