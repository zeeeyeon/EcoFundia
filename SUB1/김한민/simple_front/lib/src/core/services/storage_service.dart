import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// JWT 토큰 및 사용자 정보를 안전하게 저장하는 서비스
class StorageService {
  static const FlutterSecureStorage _storage = FlutterSecureStorage();

  // 키 상수
  static const String _tokenKey = 'jwt_token';
  static const String _userIdKey = 'user_id';
  static const String _refreshTokenKey = 'refresh_token';

  /// JWT 토큰 저장
  static Future<void> saveToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
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

  /// 사용자가 로그인되어 있는지 확인
  static Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }
}
