import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService {
  SharedPreferences? _preferences;

  bool get isReady => _preferences != null;

  Future<LocalStorageService> init() async {
    _preferences = await SharedPreferences.getInstance();
    return this;
  }

  String? readString(String key) {
    return _preferences?.getString(key);
  }

  Future<bool> writeString(String key, String value) async {
    return _preferences?.setString(key, value) ?? false;
  }

  bool? readBool(String key) {
    return _preferences?.getBool(key);
  }

  Future<bool> writeBool(String key, bool value) async {
    return _preferences?.setBool(key, value) ?? false;
  }

  int? readInt(String key) {
    return _preferences?.getInt(key);
  }

  Future<bool> writeInt(String key, int value) async {
    return _preferences?.setInt(key, value) ?? false;
  }
}
