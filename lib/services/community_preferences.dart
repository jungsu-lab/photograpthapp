import 'package:shared_preferences/shared_preferences.dart';

class CommunityPreferences {
  const CommunityPreferences();

  static const _nicknameKey = 'community-nickname-v1';

  Future<String> nickname() async {
    final preferences = await SharedPreferences.getInstance();
    return preferences.getString(_nicknameKey) ?? '';
  }

  Future<void> saveNickname(String nickname) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_nicknameKey, nickname.trim());
  }
}
