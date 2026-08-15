import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Manages secure persistence of YouTube session cookies.
///
/// Cookies are stored in the device's secure enclave (Android Keystore /
/// iOS Keychain) so they are never accessible in plain text.
class AuthService {
  static const _cookieKey = 'yt_session_cookies';

  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  /// Saves the serialized YouTube cookie string.
  Future<void> saveCookies(String cookieString) async {
    await _storage.write(key: _cookieKey, value: cookieString);
  }

  /// Returns the saved cookie string, or null if the user is not logged in.
  Future<String?> getCookies() async {
    return _storage.read(key: _cookieKey);
  }

  /// Deletes saved cookies. Call this when the user signs out.
  Future<void> clearCookies() async {
    await _storage.delete(key: _cookieKey);
  }

  /// Returns true if a cookie string has been previously saved.
  Future<bool> get isLoggedIn async {
    final cookies = await getCookies();
    return cookies != null && cookies.isNotEmpty;
  }
}
