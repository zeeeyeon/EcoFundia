import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// JWT 토큰 및 사용자 정보를 안전하게 저장하는 서비스
class StorageService {
  static const FlutterSecureStorage _storage = FlutterSecureStorage();

  // 키 상수
  static const String _tokenKey = 'jwt_token';
  static const String _userIdKey = 'user_id';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _lastLoginDateKey = 'last_login_date';
  static const String _autoLoginKey = 'auto_login';

  /// JWT 토큰 저장
  static Future<void> saveToken(String token, {Duration? expiresIn}) async {
    await _storage.write(key: _tokenKey, value: token);
    if (expiresIn != null) {
      final expiryDate = DateTime.now().add(expiresIn).toIso8601String();
      await _storage.write(key: '${_tokenKey}_expiry', value: expiryDate);
    }
  }

  /// JWT 토큰 조회
  static Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }

  /// 토큰 삭제 (로그아웃 시)
  static Future<void> deleteToken() async {
    await _storage.delete(key: _tokenKey);
  }

  /// 리프레시 토큰 저장
  static Future<void> saveRefreshToken(String token) async {
    await _storage.write(key: _refreshTokenKey, value: token);
  }

  /// 리프레시 토큰 조회
  static Future<String?> getRefreshToken() async {
    return await _storage.read(key: _refreshTokenKey);
  }

  /// 사용자 ID 저장
  static Future<void> saveUserId(String userId) async {
    await _storage.write(key: _userIdKey, value: userId);
  }

  /// 사용자 ID 조회
  static Future<String?> getUserId() async {
    return await _storage.read(key: _userIdKey);
  }

  /// 모든 사용자 데이터 삭제 (로그아웃)
  static Future<void> clearUserData() async {
    await _storage.deleteAll();
  }

  /// 자동 로그인 설정 저장
  static Future<void> setAutoLogin(bool enabled) async {
    await _storage.write(key: _autoLoginKey, value: enabled.toString());
  }

  /// 자동 로그인 상태 확인
  static Future<bool> isAutoLoginEnabled() async {
    final value = await _storage.read(key: _autoLoginKey);
    return value == 'true';
  }

  /// 마지막 로그인 시간 저장
  static Future<void> updateLastLoginDate() async {
    final now = DateTime.now().toIso8601String();
    await _storage.write(key: _lastLoginDateKey, value: now);
  }

  /// 토큰 유효성 검사
  static Future<bool> isTokenValid() async {
    try {
      final token = await getToken();
      if (token == null) return false;

      final expiryDateStr = await _storage.read(key: '${_tokenKey}_expiry');
      if (expiryDateStr == null) return false;

      final expiryDate = DateTime.parse(expiryDateStr);
      return DateTime.now().isBefore(expiryDate);
    } catch (e) {
      return false;
    }
  }

  /// 로그인 상태 확인 개선
  static Future<bool> isLoggedIn() async {
    try {
      final autoLoginEnabled = await isAutoLoginEnabled();
      if (!autoLoginEnabled) return false;

      final token = await getToken();
      if (token == null) return false;

      return await isTokenValid();
    } catch (e) {
      return false;
    }
  }

  /// 보안 로그아웃 (선택적 데이터 유지)
  static Future<void> secureLogout({bool keepUserPreferences = false}) async {
    if (keepUserPreferences) {
      // 인증 관련 데이터만 삭제
      await _storage.delete(key: _tokenKey);
      await _storage.delete(key: _refreshTokenKey);
      await _storage.delete(key: '${_tokenKey}_expiry');
    } else {
      // 모든 데이터 삭제
      await clearUserData();
    }
  }
}
