import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:front/utils/logger_util.dart';
import 'package:front/core/config/app_config.dart';
import 'token_service.dart';

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

    try {
      // 저장된 토큰 확인
      final token = await _storage.read(key: _tokenKey);
      if (token != null) {
        LoggerUtil.d('🔑 저장된 토큰 발견');

        // 토큰 유효성 검사
        if (!TokenService.isTokenExpired(token)) {
          LoggerUtil.d('✅ 토큰 유효함');
          await checkAndRefreshTokenIfNeeded();
        } else {
          LoggerUtil.w('⚠️ 토큰 만료됨');
          // 만료된 토큰 제거
          await _storage.delete(key: _tokenKey);
        }
      }
    } catch (e) {
      LoggerUtil.e('❌ 스토리지 초기화 중 오류', e);
      // 오류 발생 시 토큰 초기화
      await _storage.delete(key: _tokenKey);
    }
  }

  /// 토큰 저장 (동기화 처리)
  static Future<void> saveToken(String token) async {
    try {
      // 토큰 유효성 검사
      if (!TokenService.isValidToken(token)) {
        throw Exception('유효하지 않은 토큰 형식입니다.');
      }

      // 토큰 저장
      await _storage.write(key: _tokenKey, value: token);
      LoggerUtil.d('✅ 토큰 저장 완료');

      // 마지막 로그인 시간 업데이트
      await updateLastLoginDate();
    } catch (e) {
      LoggerUtil.e('❌ 토큰 저장 실패', e);
      // 저장 실패 시 기존 토큰 제거
      await _storage.delete(key: _tokenKey);
      rethrow;
    }
  }

  /// 사용자가 인증되어 있는지 확인
  static Future<bool> isAuthenticated() async {
    try {
      // 1. 액세스 토큰 확인
      final token = await _storage.read(key: _tokenKey);
      if (token == null) {
        LoggerUtil.d('🔑 인증 상태: 토큰 없음');
        return false;
      }

      // 2. 토큰 유효성 검사
      if (!TokenService.isValidToken(token)) {
        LoggerUtil.w('⚠️ 인증 상태: 유효하지 않은 토큰');
        return false;
      }

      // 3. 토큰 만료 확인
      if (TokenService.isTokenExpired(token)) {
        LoggerUtil.w('⚠️ 인증 상태: 만료된 토큰');

        // 리프레시 토큰 확인
        final refreshToken = await _storage.read(key: _refreshTokenKey);
        if (refreshToken != null &&
            !TokenService.isTokenExpired(refreshToken)) {
          LoggerUtil.d('🔄 인증 상태: 리프레시 토큰 유효함');
          return true;
        }

        return false;
      }

      LoggerUtil.d('✅ 인증 상태: 유효한 토큰');
      return true;
    } catch (e) {
      LoggerUtil.e('❌ 인증 상태 확인 중 오류', e);
      return false;
    }
  }

  /// 액세스 토큰의 만료 시간을 확인하고 필요한 경우 갱신
  static Future<bool> checkAndRefreshTokenIfNeeded() async {
    try {
      final token = await _storage.read(key: _tokenKey);
      if (token == null) {
        LoggerUtil.d('⚠️ 토큰 갱신 확인: 토큰이 없습니다');
        return false;
      }

      // 토큰 만료까지 남은 시간 계산 (분)
      final minutesToExpiration =
          TokenService.calculateMinutesToExpiration(token);
      if (minutesToExpiration == null) return false;

      // 만료 시간 로깅
      LoggerUtil.d('🔍 액세스 토큰 만료까지 남은 시간: $minutesToExpiration분');

      // 설정된 시간 내에 만료되는 경우 갱신 필요
      if (minutesToExpiration <=
          AppConfig.tokenConfig.refreshBeforeExpirationMinutes) {
        LoggerUtil.i('🔄 토큰 갱신 필요 (남은 시간: $minutesToExpiration분)');

        // 리프레시 토큰 확인
        final refreshToken = await getRefreshToken();
        if (refreshToken == null) {
          LoggerUtil.w('⚠️ 토큰 갱신 실패: 리프레시 토큰이 없습니다');
          return false;
        }

        // 리프레시 토큰이 만료되었는지 확인
        if (TokenService.isTokenExpired(refreshToken)) {
          LoggerUtil.w('⚠️ 토큰 갱신 실패: 리프레시 토큰이 만료되었습니다');
          return false;
        }

        // 토큰 갱신 시도
        final newTokens = await TokenService.refreshTokens(refreshToken);
        if (newTokens != null) {
          // 새 토큰 저장
          await saveToken(newTokens['accessToken']!);
          await saveRefreshToken(newTokens['refreshToken']!);
          LoggerUtil.i('✅ 예방적 토큰 갱신 성공');
          return true;
        } else {
          LoggerUtil.w('⚠️ 토큰 갱신 실패');
          return false;
        }
      }

      // 토큰이 아직 유효하고 갱신이 필요하지 않음
      return false;
    } catch (e) {
      LoggerUtil.e('❌ 토큰 만료 확인 중 오류', e);
      return false;
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

  // 사용자 닉네임 조회
  static Future<String?> getNickname() async {
    return await _storage.read(key: _userNicknameKey);
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
    try {
      // await _storage.deleteAll();
      final keys = await _storage.readAll();
      for (final key in keys.keys) {
        if (key != 'joinedChatRooms') {
          await _storage.delete(key: key);
        }
      }
      // 추가적으로 토큰 관련 키를 개별적으로 확실히 삭제
      await _storage.delete(key: _tokenKey);
      await _storage.delete(key: _refreshTokenKey);
      await _storage.delete(key: _userIdKey);
      await _storage.delete(key: _userEmailKey);
      await _storage.delete(key: _userNicknameKey);

      LoggerUtil.d('🧹 저장소 초기화 완료: 모든 인증 데이터 삭제됨');
    } catch (e) {
      LoggerUtil.e('❌ 저장소 초기화 중 오류 발생', e);
      // 오류가 발생해도 토큰은 반드시 제거 시도
      try {
        await _storage.delete(key: _tokenKey);
        await _storage.delete(key: _refreshTokenKey);
        LoggerUtil.d('🔑 토큰 제거 시도 완료');
      } catch (tokenError) {
        LoggerUtil.e('❌ 토큰 제거 중 추가 오류 발생', tokenError);
      }
    }
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
