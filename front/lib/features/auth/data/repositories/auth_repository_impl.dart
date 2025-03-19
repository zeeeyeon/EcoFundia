import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:dio/dio.dart';
import '../../domain/models/auth_response.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../../../core/services/api_service.dart';
import '../../../../core/services/storage_service.dart';
import '../../../../utils/logger_util.dart';
import 'package:front/features/auth/domain/models/auth_result.dart';
import 'package:front/features/auth/data/services/auth_service.dart';

class AuthRepositoryImpl implements AuthRepository {
  final ApiService _apiService;
  final AuthService _authService;
  final GoogleSignIn _googleSignIn;

  AuthRepositoryImpl(this._apiService, this._authService)
      : _googleSignIn = _authService.googleSignIn;

  @override
  Future<String?> getGoogleAccessToken() async {
    try {
      LoggerUtil.i('🔑 Repository - Google 액세스 토큰 요청');
      return await _authService.getGoogleAccessToken();
    } catch (e) {
      LoggerUtil.e('❌ Repository - Google 로그인 중 오류 발생', e);
      throw Exception('Google 로그인 중 오류가 발생했습니다: $e');
    }
  }

  @override
  Future<AuthResponse> authenticateWithGoogle(String accessToken) async {
    try {
      LoggerUtil.i('🔄 서버에 Google 인증 요청 중...');

      // 응답이 null인지 검증
      final response = await _apiService
          .post(ApiService.loginEndpoint, data: {'token': accessToken});

      LoggerUtil.i('✅ 서버 응답 수신 완료');

      if (response.data == null) {
        LoggerUtil.e('❌ 서버 응답이 null입니다.');
        throw Exception('서버 응답이 올바르지 않습니다.');
      }

      // 응답 데이터 파싱
      final authResponse = AuthResponse.fromJson(response.data);

      // JWT 토큰 저장
      if (authResponse.accessToken != null) {
        await StorageService.saveToken(authResponse.accessToken!);
      }

      // Refresh 토큰 저장
      if (authResponse.refreshToken != null) {
        await StorageService.saveRefreshToken(authResponse.refreshToken!);
      }

      // 사용자 ID 저장
      if (authResponse.user?.userId != null) {
        await StorageService.saveUserId(authResponse.user!.userId.toString());
      }

      LoggerUtil.i('✅ 인증 성공');
      return authResponse;
    } on DioException catch (e) {
      final statusCode = e.response?.statusCode;
      LoggerUtil.e('❌ API 요청 실패: 상태코드=$statusCode', e);

      switch (statusCode) {
        case 400:
          throw Exception('잘못된 액세스 토큰입니다.');
        case 401:
          throw Exception('인증에 실패했습니다.');
        case 404:
          // 404는 회원가입이 필요한 상태
          LoggerUtil.i('ℹ️ Repository - 신규 사용자 감지 (404)');
          String message = '해당 이메일로 가입된 사용자가 없습니다. 회원가입이 필요합니다.';
          try {
            if (e.response?.data != null &&
                e.response?.data['message'] != null) {
              message = e.response!.data['message'];
            }
          } catch (_) {}
          throw AuthException(message, 404);
        case 500:
          throw Exception('서버 오류가 발생했습니다.');
        default:
          throw Exception('인증 중 오류가 발생했습니다: ${e.message}');
      }
    } catch (e) {
      LoggerUtil.e('❌ 기타 오류 발생', e);
      throw Exception('인증 중 오류가 발생했습니다: $e');
    }
  }

  @override
  Future<AuthResponse> completeSignUp(Map<String, dynamic> userData) async {
    try {
      LoggerUtil.i('📝 회원가입 요청 중...');

      // 토큰 정보 로깅
      if (userData.containsKey('token')) {
        final token = userData['token'];
        if (token != null) {
          LoggerUtil.i('🔑 회원가입 데이터에 토큰이 포함됨');
        } else {
          LoggerUtil.w('⚠️ 회원가입 데이터에 토큰이 null로 설정되어 있습니다.');
        }
      } else {
        LoggerUtil.w('⚠️ 회원가입 데이터에 token 키가 없습니다.');
      }

      final response =
          await _apiService.post(ApiService.signupEndpoint, data: userData);

      if (response.data == null) {
        LoggerUtil.e('❌ 서버 응답이 null입니다.');
        throw Exception('서버 응답이 올바르지 않습니다.');
      }

      // 회원가입 응답 데이터 파싱
      final authResponse = AuthResponse.fromJson(response.data);

      // JWT 토큰 저장
      if (authResponse.accessToken != null) {
        await StorageService.saveToken(authResponse.accessToken!);
      }

      // Refresh 토큰 저장
      if (authResponse.refreshToken != null) {
        await StorageService.saveRefreshToken(authResponse.refreshToken!);
      }

      // 사용자 정보 저장
      if (authResponse.user != null) {
        await StorageService.saveUserId(authResponse.user!.userId.toString());
        await StorageService.saveUserEmail(authResponse.user!.email);
        await StorageService.saveUserNickname(authResponse.user!.nickname);
      }

      LoggerUtil.i('✅ 회원가입 완료 성공');
      return authResponse;
    } on DioException catch (e) {
      LoggerUtil.e('❌ 회원가입 API 요청 실패', e);

      switch (e.response?.statusCode) {
        case 400:
          throw Exception('회원가입 정보가 올바르지 않습니다.');
        case 409:
          throw Exception('이미 존재하는 회원입니다.');
        case 500:
          throw Exception('서버 오류가 발생했습니다.');
        default:
          throw Exception('회원가입 중 오류가 발생했습니다: ${e.message}');
      }
    } catch (e) {
      LoggerUtil.e('❌ 회원가입 완료 중 오류 발생', e);
      throw Exception('회원가입 완료 중 오류가 발생했습니다: $e');
    }
  }

  @override
  Future<void> signOut() async {
    try {
      LoggerUtil.i('🚪 Repository - 로그아웃 시작');

      // Google 로그아웃
      await _googleSignIn.signOut();
      await _authService.signOut();
      LoggerUtil.i('✅ Google 로그아웃 완료');

      // 로컬 토큰 삭제
      await StorageService.clearAll();
      LoggerUtil.i('✅ 로컬 사용자 데이터 삭제 완료');

      // 서버에 로그아웃 알림 (선택적)
      try {
        await _apiService.post(ApiService.logoutEndpoint);
        LoggerUtil.i('✅ 서버 로그아웃 요청 완료');
      } catch (e) {
        LoggerUtil.w('⚠️ 서버 로그아웃 요청 실패 (무시됨)');
      }
    } catch (e) {
      LoggerUtil.e('❌ Repository - 로그아웃 중 오류 발생', e);

      // 로그아웃 실패 시 로컬 데이터만 삭제
      await StorageService.clearAll();
      LoggerUtil.i('✅ 로컬 사용자 데이터 강제 삭제 완료');

      rethrow;
    }
  }

  @override
  Future<bool> isLoggedIn() async {
    try {
      LoggerUtil.i('🔍 Repository - 로그인 상태 확인 중...');
      final isLoggedIn = await StorageService.hasValidToken();
      LoggerUtil.i('✅ Repository - 로그인 상태: $isLoggedIn');
      return isLoggedIn;
    } catch (e) {
      LoggerUtil.e('❌ Repository - 로그인 상태 확인 중 오류 발생', e);
      return false;
    }
  }

  @override
  Future<bool> checkLoginStatus() => isLoggedIn();

  @override
  Future<AuthResult> signInWithGoogle() async {
    LoggerUtil.i('🔑 Repository - Google 로그인 시작');
    try {
      // 1. 구글 액세스 토큰 획득
      final accessToken = await getGoogleAccessToken();

      if (accessToken == null) {
        LoggerUtil.w('⚠️ Repository - 액세스 토큰이 null (사용자 취소)');
        return const AuthResult.cancelled();
      }

      // 2. 서버 인증 및 토큰 획득
      LoggerUtil.i('🔄 Repository - 서버 인증 요청 중...');

      try {
        final response = await _authService.authenticateWithGoogle(accessToken);
        if (response.user != null) {
          LoggerUtil.i('✅ Repository - 서버 인증 성공');
          return AuthResult.success(response);
        } else {
          LoggerUtil.i('ℹ️ Repository - 신규 사용자 감지');
          return const AuthResult.newUser('회원가입이 필요합니다.');
        }
      } catch (e) {
        if (e is AuthException && e.statusCode == 404) {
          // 404는 회원가입이 필요한 상태
          LoggerUtil.i('ℹ️ Repository - 신규 사용자 감지 (404)');
          return AuthResult.newUser(e.message);
        }
        rethrow;
      }
    } catch (e) {
      LoggerUtil.e('❌ Repository - Google 로그인 중 오류 발생', e);
      if (e is AuthException) {
        return AuthResult.error(e.message, statusCode: e.statusCode);
      }
      return const AuthResult.error('로그인 중 오류가 발생했습니다.');
    }
  }

  @override
  Future<Map<String, dynamic>?> getGoogleUserInfo() async {
    try {
      LoggerUtil.i('🔍 Repository - Google 사용자 정보 요청');

      // Google 계정 정보 획득
      final account =
          await _googleSignIn.signInSilently() ?? await _googleSignIn.signIn();
      if (account == null) {
        LoggerUtil.w('⚠️ Repository - Google 사용자 정보 획득 실패: 계정 없음');
        return null;
      }

      // 기본 정보 반환
      final userInfo = {
        'email': account.email,
        'name': account.displayName,
      };

      LoggerUtil.i('✅ Repository - Google 사용자 정보 획득 성공: $userInfo');
      return userInfo;
    } catch (e) {
      LoggerUtil.e('❌ Repository - Google 사용자 정보 획득 중 오류', e);
      return null;
    }
  }
}
