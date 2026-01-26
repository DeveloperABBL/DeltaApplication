import 'package:flutter_secure_storage/flutter_secure_storage.dart';

mixin AppLocalSecureStoreMixin {
  Future<String?> readSecure(String key);
  Future<void> writeSecure({required String key, required String value});
  Future<void> deleteSecure(String key);
  Future<void> deleteAllSecure();
}

class AppLocalSecureStorage with AppLocalSecureStoreMixin {
  AppLocalSecureStorage._();
  static final _instance = AppLocalSecureStorage._();

  factory AppLocalSecureStorage.instance() => _instance;

  final _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock,
    ),
  );

  @override
  Future<String?> readSecure(String key) async {
    return await _storage.read(key: key);
  }

  @override
  Future<void> writeSecure({required String key, required String value}) async {
    await _storage.write(key: key, value: value);
  }

  @override
  Future<void> deleteSecure(String key) async {
    await _storage.delete(key: key);
  }

  @override
  Future<void> deleteAllSecure() async {
    await _storage.deleteAll();
  }
}
