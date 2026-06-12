import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class StorageService {
  static const storage =
      FlutterSecureStorage();

  static Future<void> saveToken(
    String token,
  ) async {
    await storage.write(
      key: 'token',
      value: token,
    );
  }

  static Future<String?> getToken() async {
    return storage.read(
      key: 'token',
    );
  }

  static Future<void> logout() async {
    await storage.deleteAll();
  }
}