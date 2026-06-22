import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class StorageService {
  static const _introCompletedKey = 'introCompleted';
  static const storage = FlutterSecureStorage();

  static Future<void> saveToken(String token) async {
    await storage.write(key: 'token', value: token);
  }

  static Future<String?> getToken() async {
    return storage.read(key: 'token');
  }

  static Future<void> saveIntroCompleted() async {
    await storage.write(key: _introCompletedKey, value: 'true');
  }

  static Future<bool> hasCompletedIntro() async {
    final value = await storage.read(key: _introCompletedKey);
    return value == 'true';
  }

  static Future<void> logout() async {
    await storage.delete(key: 'token');
  }
}
