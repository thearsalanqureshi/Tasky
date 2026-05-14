import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants/storage_keys.dart';

class LocalStorageService {
  SharedPreferences? _preferences;

  bool get isReady => _preferences != null;

  Future<LocalStorageService> init() async {
    _preferences = await SharedPreferences.getInstance();
    return this;
  }

  String? getString(String key, {String? fallback}) {
    try {
      return _preferences?.getString(key) ?? fallback;
    } catch (_) {
      return fallback;
    }
  }

  Future<bool> setString(String key, String value) async {
    try {
      return await _preferences?.setString(key, value) ?? false;
    } catch (_) {
      return false;
    }
  }

  bool? getBool(String key, {bool? fallback}) {
    try {
      return _preferences?.getBool(key) ?? fallback;
    } catch (_) {
      return fallback;
    }
  }

  Future<bool> setBool(String key, bool value) async {
    try {
      return await _preferences?.setBool(key, value) ?? false;
    } catch (_) {
      return false;
    }
  }

  int? getInt(String key, {int? fallback}) {
    try {
      return _preferences?.getInt(key) ?? fallback;
    } catch (_) {
      return fallback;
    }
  }

  Future<bool> setInt(String key, int value) async {
    try {
      return await _preferences?.setInt(key, value) ?? false;
    } catch (_) {
      return false;
    }
  }

  Future<bool> remove(String key) async {
    try {
      return await _preferences?.remove(key) ?? false;
    } catch (_) {
      return false;
    }
  }

  List<Map<String, dynamic>> getJsonList(String key) {
    final rawValue = getString(key);
    if (rawValue == null || rawValue.trim().isEmpty) {
      return const [];
    }
    try {
      final decoded = jsonDecode(rawValue);
      if (decoded is! List) {
        return const [];
      }
      return decoded
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .toList();
    } catch (_) {
      return const [];
    }
  }

  Future<bool> setJsonList(
    String key,
    List<Map<String, dynamic>> values,
  ) async {
    try {
      return await setString(key, jsonEncode(values));
    } catch (_) {
      return false;
    }
  }

  Map<String, dynamic> getJsonMap(String key) {
    final rawValue = getString(key);
    if (rawValue == null || rawValue.trim().isEmpty) {
      return const {};
    }
    try {
      final decoded = jsonDecode(rawValue);
      if (decoded is! Map) {
        return const {};
      }
      return Map<String, dynamic>.from(decoded);
    } catch (_) {
      return const {};
    }
  }

  Future<bool> setJsonMap(String key, Map<String, dynamic> value) async {
    try {
      return await setString(key, jsonEncode(value));
    } catch (_) {
      return false;
    }
  }

  Future<bool> clearTaskyData() async {
    var allSucceeded = true;
    for (final key in StorageKeys.taskyKeys) {
      allSucceeded = await remove(key) && allSucceeded;
    }
    return allSucceeded;
  }

  // Backward-compatible names from Phase 1.
  String? readString(String key) => getString(key);

  Future<bool> writeString(String key, String value) {
    return setString(key, value);
  }

  bool? readBool(String key) => getBool(key);

  Future<bool> writeBool(String key, bool value) {
    return setBool(key, value);
  }

  int? readInt(String key) => getInt(key);

  Future<bool> writeInt(String key, int value) {
    return setInt(key, value);
  }
}
