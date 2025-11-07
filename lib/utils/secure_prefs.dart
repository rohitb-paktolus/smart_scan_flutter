import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecurePrefs {
  // Private constructor
  SecurePrefs._internal();

  static final SecurePrefs _instance = SecurePrefs._internal();

  factory SecurePrefs() => _instance;

  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<void> setString(String key, String value) async {
    await _storage.write(key: key, value: value);
  }

  Future<String> getString(String key) async {
    return await _storage.read(key: key) ?? "";
  }

  Future<void> deleteValue(String key) async {
    await _storage.delete(key: key);
  }
}