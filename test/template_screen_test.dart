import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:framefit/features/templates/template_screen.dart';

void main() {
  testWidgets('favorite filter explains an empty favorite library', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    await tester.pumpWidget(
      const MaterialApp(home: TemplateScreen(embedded: true)),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('즐겨찾기'));
    await tester.pumpAndSettle();

    expect(find.text('즐겨찾는 프리셋이 아직 없어요.'), findsOneWidget);
    await tester.tap(find.text('모든 프리셋 보기'));
    await tester.pumpAndSettle();
    expect(find.text('즐겨찾는 프리셋이 아직 없어요.'), findsNothing);
  });
}
