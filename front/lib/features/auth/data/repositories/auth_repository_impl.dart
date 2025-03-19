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
import 'package:front/features/auth/data/models/sign_up_model.dart';
import 'package:front/core/exceptions/auth_exception.dart';

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
          .post(ApiService.apiEndpoints.login, data: {'token': accessToken});

      LoggerUtil.i('✅ 서버 응답 수신 완료');

      if (response.data == null) {
        LoggerUtil.e('❌ 서버 응답이 null입니다.');
        throw AuthException('서버 응답이 올바르지 않습니다.');
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
          throw AuthException('잘못된 액세스 토큰입니다.', statusCode: 400);
        case 401:
          throw AuthException('인증에 실패했습니다.', statusCode: 401);
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
          throw AuthException(message, statusCode: 404);
        case 500:
          throw AuthException('서버 오류가 발생했습니다.', statusCode: 500);
        default:
          throw AuthException('인증 중 오류가 발생했습니다: ${e.message}');
      }
    } catch (e) {
      LoggerUtil.e('❌ 기타 오류 발생', e);
      throw AuthException('인증 중 오류가 발생했습니다: $e');
    }
  }

  @override
  Future<AuthResponse> completeSignUp(SignUpModel signUpData) async {
    try {
      LoggerUtil.i('📝 회원가입 요청 중...');

      // 토큰 정보 로깅
      if (signUpData.token != null) {
        LoggerUtil.i('🔑 회원가입 데이터에 token이 포함됨');
      } else {
        LoggerUtil.w('⚠️ 회원가입 데이터에 token이 없습니다.');
      }

      // 모델을 JSON 데이터로 변환
      final userData = signUpData.toJson();

      // 백엔드에 전송할 데이터 준비 완료
      final response = await _apiService.post(ApiService.apiEndpoints.signup,
          data: userData);

      if (response.data == null) {
        LoggerUtil.e('❌ 서버 응답이 null입니다.');
        throw AuthException('서버 응답이 올바르지 않습니다.');
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
          throw AuthException('회원가입 정보가 올바르지 않습니다.', statusCode: 400);
        case 409:
          throw AuthException('이미 존재하는 회원입니다.', statusCode: 409);
        case 500:
          throw AuthException('서버 오류가 발생했습니다.', statusCode: 500);
        default:
          throw AuthException('회원가입 중 오류가 발생했습니다: ${e.message}');
      }
    } catch (e) {
      LoggerUtil.e('❌ 회원가입 완료 중 오류 발생', e);
      if (e is AuthException) {
        rethrow;
      }
      throw AuthException('회원가입 완료 중 오류가 발생했습니다: $e');
    }
  }

  @override
  Future<AuthResponse> completeSignUpWithMap(
      Map<String, dynamic> userData) async {
    try {
      LoggerUtil.i('📝 회원가입 요청 중... (Map 데이터 사용)');

      // 필수 필드 검증
      if (!userData.containsKey('email') ||
          !userData.containsKey('nickname') ||
          !userData.containsKey('gender') ||
          !userData.containsKey('age')) {
        throw AuthException('필수 회원정보가 누락되었습니다.');
      }

      // 토큰 검증
      if (!userData.containsKey('token') || userData['token'] == null) {
        LoggerUtil.w('⚠️ 회원가입 데이터에 token이 없습니다.');
      }

      // SignUpModel로 변환
      final signUpModel = SignUpModel(
        email: userData['email'] as String,
        nickname: userData['nickname'] as String,
        gender: userData['gender'] as String,
        age: userData['age'] as int,
        token: userData['token'] as String?,
      );

      // 기존 메서드 호출
      return await completeSignUp(signUpModel);
    } catch (e) {
      LoggerUtil.e('❌ 회원가입 완료 중 오류 발생 (Map 데이터)', e);
      if (e is AuthException) {
        rethrow;
      }
      throw AuthException('회원가입 완료 중 오류가 발생했습니다: $e');
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
        await _apiService.post(ApiService.apiEndpoints.logout);
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
