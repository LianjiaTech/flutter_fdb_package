import 'package:shared_preferences/shared_preferences.dart';

const String kFloatingDotPos = 'FloatingDotPos';

class KitStoreManager {
  static KitStoreManager _instance;

  static KitStoreManager get instance {
    if (_instance == null) {
      _instance = KitStoreManager._();
    }
    return _instance;
  }

  Future<SharedPreferences> _sharedPref;

  KitStoreManager._() {
    _sharedPref = SharedPreferences.getInstance();
  }

  Future<String> fetchFloatingDotPos() async {
    final SharedPreferences prefs = await _sharedPref;
    return prefs.getString(kFloatingDotPos);
  }

  void storeFloatingDotPos(double x, double y) async {
    final SharedPreferences prefs = await _sharedPref;
    prefs.setString(kFloatingDotPos, "$x,$y");
  }
}
