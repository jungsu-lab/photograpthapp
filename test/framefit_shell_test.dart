import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:framefit/features/shell/framefit_shell.dart';

void main() {
  testWidgets('shell exposes home, shoot, and edit destinations', (
    tester,
  ) async {
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
}
