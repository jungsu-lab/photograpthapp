import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:framefit/core/widgets/premium_widgets.dart';

void main() {
  Widget host(Widget child) {
    return MaterialApp(home: Scaffold(body: child));
  }

  testWidgets('CategoryChip exposes selected and unselected states', (
    tester,
  ) async {
    var selected = false;

    await tester.pumpWidget(
      host(
        StatefulBuilder(
          builder: (context, setState) {
            return CategoryChip(
              label: '음식',
              selected: selected,
              onTap: () => setState(() => selected = true),
            );
          },
        ),
      ),
    );

    expect(find.byKey(const Key('categoryChip-음식')), findsOneWidget);
    expect(find.byIcon(Icons.check), findsNothing);

    await tester.tap(find.byKey(const Key('categoryChip-음식')));
    await tester.pump();

    expect(find.byIcon(Icons.check), findsOneWidget);
  });

  testWidgets('GhostButton and EmptyState provide practical shared states', (
    tester,
  ) async {
    var tapped = false;

    await tester.pumpWidget(
      host(
        Column(
          children: [
            GhostButton(
              label: '다시 보기',
              icon: Icons.refresh,
              onPressed: () => tapped = true,
            ),
            const EmptyState(
              icon: Icons.photo_library_outlined,
              title: '아직 사진이 없어요',
              description: '촬영하거나 템플릿을 골라 시작하세요.',
            ),
          ],
        ),
      ),
    );

    await tester.tap(find.text('다시 보기'));
    await tester.pump();

    expect(tapped, isTrue);
    expect(find.text('아직 사진이 없어요'), findsOneWidget);
    expect(find.text('촬영하거나 템플릿을 골라 시작하세요.'), findsOneWidget);
  });
}
