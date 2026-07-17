import 'package:shared_preferences/shared_preferences.dart';

class CompositionPreferences {
  const CompositionPreferences();

  static const favoritesKey = 'favorite-composition-ids-v1';

  Future<Set<String>> favorites() async {
    final preferences = await SharedPreferences.getInstance();
    return preferences.getStringList(favoritesKey)?.toSet() ?? <String>{};
  }

  Future<Set<String>> toggleFavorite(String id) async {
    final preferences = await SharedPreferences.getInstance();
    final values =
        preferences.getStringList(favoritesKey)?.toSet() ?? <String>{};
    if (!values.add(id)) values.remove(id);
    await preferences.setStringList(favoritesKey, values.toList()..sort());
    return values;
  }
}
