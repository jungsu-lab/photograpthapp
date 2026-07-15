import 'package:shared_preferences/shared_preferences.dart';

class PresetPreferences {
  static const _favoritesKey = 'favorite-preset-ids-v1';
  static const _recentKey = 'recent-preset-ids-v1';

  Future<Set<String>> favorites() async {
    final preferences = await SharedPreferences.getInstance();
    return preferences.getStringList(_favoritesKey)?.toSet() ?? <String>{};
  }

  Future<Set<String>> toggleFavorite(String id) async {
    final preferences = await SharedPreferences.getInstance();
    final values =
        preferences.getStringList(_favoritesKey)?.toSet() ?? <String>{};
    if (!values.add(id)) values.remove(id);
    await preferences.setStringList(_favoritesKey, values.toList()..sort());
    return values;
  }

  Future<void> recordUse(String id) async {
    final preferences = await SharedPreferences.getInstance();
    final values = preferences.getStringList(_recentKey) ?? <String>[];
    values.remove(id);
    values.insert(0, id);
    await preferences.setStringList(_recentKey, values.take(6).toList());
  }

  Future<List<String>> recentIds() async {
    final preferences = await SharedPreferences.getInstance();
    return preferences.getStringList(_recentKey) ?? const <String>[];
  }
}
