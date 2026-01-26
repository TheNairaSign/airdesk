import 'package:shared_preferences/shared_preferences.dart';

class DeskCacheService {
  static const String _deskCodesKey = 'cached_desk_codes';

  Future<void> cacheDeskCode(String code) async {
    if (!code.startsWith('@')) {
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final List<String> cachedCodes = prefs.getStringList(_deskCodesKey) ?? [];

    if (!cachedCodes.contains(code)) {
      cachedCodes.add(code);
      await prefs.setStringList(_deskCodesKey, cachedCodes);
    }
  }

  Future<List<String>> getCachedDeskCodes() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_deskCodesKey) ?? [];
  }
}
