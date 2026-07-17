import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:framefit/data/composition/composition_catalog.dart';
import 'package:framefit/features/shooting/shooting_library_screen.dart';
import 'package:framefit/services/composition_preferences.dart';

void main() {
  testWidgets('composition favorite persists and filters the library', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final favorite = compositionCatalog.first;
    final other = compositionCatalog[1];

    await tester.pumpWidget(const MaterialApp(home: ShootingLibraryScreen()));
    await tester.pumpAndSettle();

    await tester.tap(
      find.byKey(ValueKey('composition-favorite-${favorite.id}')),
    );
    await tester.pumpAndSettle();

    final preferences = await SharedPreferences.getInstance();
    expect(
      preferences.getStringList(CompositionPreferences.favoritesKey),
      contains(favorite.id),
    );

    await tester.tap(
      find.byKey(const ValueKey('composition-favorites-filter')),
    );
    await tester.pumpAndSettle();

    expect(find.text(favorite.name), findsOneWidget);
    expect(find.text(other.name), findsNothing);
  });

  testWidgets('empty favorites state can return to all compositions', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    await tester.pumpWidget(const MaterialApp(home: ShootingLibraryScreen()));
    await tester.pumpAndSettle();

    await tester.tap(
      find.byKey(const ValueKey('composition-favorites-filter')),
    );
    await tester.pumpAndSettle();

    expect(find.text('즐겨찾는 구도가 아직 없어요.'), findsOneWidget);
    await tester.tap(find.text('모든 구도 보기'));
    await tester.pumpAndSettle();
    expect(find.text(compositionCatalog.first.name), findsOneWidget);
  });
}
