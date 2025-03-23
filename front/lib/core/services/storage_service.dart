import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:front/utils/logger_util.dart';
import 'package:front/core/config/app_config.dart';

/// JWT 토큰 및 사용자 정보를 안전하게 저장하는 서비스
class StorageService {
  static const FlutterSecureStorage _storage = FlutterSecureStorage();

  // 키 상수
  static const String _tokenKey = 'auth_token';
  static const String _userIdKey = 'user_id';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _userEmailKey = 'user_email';
  static const String _userNicknameKey = 'user_nickname';
  static const String _lastLoginKey = 'last_login';

  /// 스토리지 서비스 초기화
  static Future<void> init() async {
    LoggerUtil.d('📦 스토리지 서비스 초기화');
    // 필요한 경우 여기에 스토리지 초기화 코드를 추가

    // 저장된 토큰 확인 (디버깅용)
    if (await isAuthenticated()) {
      LoggerUtil.d('🔑 유효한 인증 토큰이 존재합니다');

      // 토큰 만료 시간 확인 및 필요시 갱신
      await checkAndRefreshTokenIfNeeded();
    }
  }

  /// 사용자가 인증되어 있는지 확인
  /// 액세스 토큰이 유효하거나 리프레시 토큰이 있으면 인증된 것으로 간주
  static Future<bool> isAuthenticated() async {
    try {
      // 1. 액세스 토큰 확인
      final token = await _storage.read(key: _tokenKey);
      if (token != null) {
        // JWT 토큰 만료 시간 확인
        if (!JwtDecoder.isExpired(token)) {
          return true;
        }

        // 토큰이 만료되었지만 리프레시 토큰이 있는 경우
        final refreshToken = await _storage.read(key: _refreshTokenKey);
        return refreshToken != null && !JwtDecoder.isExpired(refreshToken);
      }

      return false;
    } catch (e) {
      LoggerUtil.e('❌ 인증 상태 확인 중 오류 발생', e);
      return false;
    }
  }

  /// 액세스 토큰의 만료 시간을 확인하고 필요한 경우 갱신
  static Future<bool> checkAndRefreshTokenIfNeeded() async {
    try {
      final token = await _storage.read(key: _tokenKey);
      if (token == null) return false;

      // 토큰 만료까지 남은 시간 계산 (분)
      final decodedToken = JwtDecoder.decode(token);
      final expirationTime = DateTime.fromMillisecondsSinceEpoch(
        decodedToken['exp'] * 1000,
      );
      final now = DateTime.now();
      final minutesToExpiration = expirationTime.difference(now).inMinutes;

      // 설정된 시간 내에 만료되는 경우 갱신
      if (minutesToExpiration <=
          AppConfig.tokenConfig.refreshBeforeExpirationMinutes) {
        LoggerUtil.i('🔄 토큰이 곧 만료됩니다. 자동 갱신 시작 (남은 시간: $minutesToExpiration분)');
        // 실제 토큰 갱신은 ApiService에서 수행합니다.
        // 여기서는 ApiService를 직접 호출하지 않고, 다음 API 요청 시 인터셉터에서 처리됩니다.
        return true;
      }

      return false;
    } catch (e) {
      LoggerUtil.e('❌ 토큰 만료 확인 중 오류 발생', e);
      return false;
    }
  }

  /// 액세스 토큰 저장
  static Future<void> saveToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
    await updateLastLoginDate(); // 마지막 로그인 시간 업데이트
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

  /// 사용자 이메일 저장
  static Future<void> saveUserEmail(String email) async {
    await _storage.write(key: _userEmailKey, value: email);
  }

  /// 사용자 닉네임 저장
  static Future<void> saveUserNickname(String nickname) async {
    await _storage.write(key: _userNicknameKey, value: nickname);
  }

  /// 마지막 로그인 시간 업데이트
  static Future<void> updateLastLoginDate() async {
    final now = DateTime.now().toIso8601String();
    await _storage.write(key: _lastLoginKey, value: now);
  }

  /// 저장된 데이터 모두 삭제
  static Future<void> clearAll() async {
    await _storage.deleteAll();
  }

  /// 선택적 데이터 유지 로그아웃
  static Future<void> secureLogout({bool keepUserPreferences = false}) async {
    if (keepUserPreferences) {
      // 마지막 로그인 시간만 유지
      await _storage.delete(key: _tokenKey);
      await _storage.delete(key: _refreshTokenKey);
      await _storage.delete(key: _userIdKey);
      await _storage.delete(key: _userEmailKey);
      await _storage.delete(key: _userNicknameKey);
    } else {
      await clearAll();
    }
  }

  /// 저장된 데이터 조회
  static Future<Map<String, String?>> getAllData() async {
    return {
      _tokenKey: await _storage.read(key: _tokenKey),
      _refreshTokenKey: await _storage.read(key: _refreshTokenKey),
      _userIdKey: await _storage.read(key: _userIdKey),
      _userEmailKey: await _storage.read(key: _userEmailKey),
      _userNicknameKey: await _storage.read(key: _userNicknameKey),
      _lastLoginKey: await _storage.read(key: _lastLoginKey),
    };
  }

  /// 사용자 역할 저장
  static Future<void> saveUserRole(String role) async {
    await _storage.write(key: 'user_role', value: role);
    LoggerUtil.i('✅ 사용자 역할 저장됨: $role');
  }

  /// 사용자 역할 조회
  static Future<String?> getUserRole() async {
    return await _storage.read(key: 'user_role');
  }
}
