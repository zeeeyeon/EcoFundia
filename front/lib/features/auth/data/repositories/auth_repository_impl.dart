import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:dio/dio.dart';
import '../../domain/models/auth_response.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../../../core/services/api_service.dart';
import '../../../../core/services/storage_service.dart';
import '../../../../utils/logger_util.dart';

class AuthRepositoryImpl implements AuthRepository {
  final ApiService _apiService;
  late final GoogleSignIn _googleSignIn;

  AuthRepositoryImpl(this._apiService) {
    if (kIsWeb) {
      LoggerUtil.i('🔧 Google Sign In - 웹 환경 설정');
      _googleSignIn = GoogleSignIn(
        clientId:
            '609004819005-m2h2elam67hkc5f6r7oajvhpc5555du8.apps.googleusercontent.com',
        scopes: ['email', 'profile'],
      );
    } else {
      LoggerUtil.i('🔧 Google Sign In - 모바일 환경 설정');
      _googleSignIn = GoogleSignIn(
        scopes: ['email', 'profile'],
        serverClientId:
            '609004819005-h718agaqj9pgv1t7ja6sr8rq3n0ffeqv.apps.googleusercontent.com',
      );
    }
  }

  @override
  Future<String?> getGoogleAccessToken() async {
    try {
      LoggerUtil.i('🔑 Google 로그인 프로세스 시작');

      // Google 로그인 UI 표시
      final account = await _googleSignIn.signIn();
      if (account == null) {
        LoggerUtil.w('⚠️ 사용자가 Google 로그인을 취소했습니다.');
        return null; // 사용자가 로그인 취소
      }

      LoggerUtil.i('👤 Google 계정 선택 완료: ${account.email}');
      LoggerUtil.i('🔄 인증 정보 요청 중...');

      // 인증 정보 획득
      final googleAuth = await account.authentication;

      // 인증 정보를 안전하게 로깅
      LoggerUtil.logAuthInfo({
        'accessToken': googleAuth.accessToken,
        'idToken': googleAuth.idToken,
        'serverAuthCode': googleAuth.serverAuthCode,
      });

      // 웹과 모바일 모두 액세스 토큰을 사용하도록 통일
      // 서버에게 전달할 토큰
      final accessToken = googleAuth.accessToken;

      if (accessToken == null) {
        LoggerUtil.e('⚠️ 액세스 토큰을 획득하지 못했습니다.');
        throw Exception('액세스 토큰을 획득하지 못했습니다.');
      }

      LoggerUtil.i('✅ 액세스 토큰 획득 성공: ${LoggerUtil.safeToken(accessToken)}');
      return accessToken;
    } catch (e) {
      LoggerUtil.e('❌ Google 로그인 중 오류 발생', e);
      throw Exception('Google 로그인 중 오류가 발생했습니다: $e');
    }
  }

  @override
  Future<AuthResponse> authenticateWithGoogle(String accessToken) async {
    try {
      LoggerUtil.i('🔄 서버에 액세스 토큰 전송 중...');
      LoggerUtil.i('🔒 전송할 액세스 토큰: ${LoggerUtil.safeToken(accessToken)}');

      // 응답이 null인지 검증
      final response = await _apiService
          .post('/auth/google', data: {'accessToken': accessToken});

      LoggerUtil.i('✅ 서버 응답 수신 완료');

      if (response.data == null) {
        LoggerUtil.e('❌ 서버 응답이 null입니다.');
        throw Exception('서버 응답이 올바르지 않습니다.');
      }

      LoggerUtil.i('🔄 응답 데이터 파싱 중...');
      final authResponse = AuthResponse.fromJson(response.data);
      LoggerUtil.i('✅ 응답 파싱 완료: isNewUser=${authResponse.isNewUser}');

      // JWT 토큰 저장
      if (authResponse.token != null) {
        LoggerUtil.i(
            '💾 JWT 토큰 저장 중: ${LoggerUtil.safeToken(authResponse.token)}');
        await StorageService.saveToken(authResponse.token!);
      }

      // Refresh 토큰 저장
      if (authResponse.refreshToken != null) {
        LoggerUtil.i(
            '💾 Refresh 토큰 저장 중: ${LoggerUtil.safeToken(authResponse.refreshToken)}');
        await StorageService.saveRefreshToken(authResponse.refreshToken!);
      }

      // 사용자 ID 저장
      if (authResponse.userId != null) {
        LoggerUtil.i('💾 사용자 ID 저장 중: ${authResponse.userId}');
        await StorageService.saveUserId(authResponse.userId!);
      }

      LoggerUtil.i('✅ 인증 프로세스 성공적으로 완료');
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
          throw Exception('서버를 찾을 수 없습니다.');
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
      LoggerUtil.i('📝 회원가입 데이터 전송 중...');
      final response = await _apiService.post('/auth/signup', data: userData);

      if (response.data == null) {
        LoggerUtil.e('❌ 서버 응답이 null입니다.');
        throw Exception('서버 응답이 올바르지 않습니다.');
      }

      LoggerUtil.i('🔄 회원가입 응답 데이터 파싱 중...');
      final authResponse = AuthResponse.fromJson(response.data);

      // JWT 토큰 저장
      if (authResponse.token != null) {
        LoggerUtil.i('💾 JWT 토큰 저장 중');
        await StorageService.saveToken(authResponse.token!);
      }

      // Refresh 토큰 저장
      if (authResponse.refreshToken != null) {
        LoggerUtil.i('💾 Refresh 토큰 저장 중');
        await StorageService.saveRefreshToken(authResponse.refreshToken!);
      }

      // 사용자 ID 저장
      if (authResponse.userId != null) {
        LoggerUtil.i('💾 사용자 ID 저장 중: ${authResponse.userId}');
        await StorageService.saveUserId(authResponse.userId!);
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
      LoggerUtil.i('🔑 로그아웃 시작');

      // Google 로그아웃
      await _googleSignIn.signOut();
      LoggerUtil.i('✅ Google 로그아웃 완료');

      // 로컬 토큰 삭제
      await StorageService.clearUserData();
      LoggerUtil.i('✅ 로컬 사용자 데이터 삭제 완료');

      // 서버에 로그아웃 알림 (선택적)
      await _apiService.post('/auth/logout');
      LoggerUtil.i('✅ 서버 로그아웃 요청 완료');
    } catch (e) {
      LoggerUtil.e('❌ 로그아웃 중 오류 발생', e);

      // 로그아웃 실패 시 로컬 데이터만 삭제
      await StorageService.clearUserData();
      LoggerUtil.i('✅ 로컬 사용자 데이터 강제 삭제 완료');

      throw Exception('로그아웃 중 오류가 발생했습니다: $e');
    }
  }

  @override
  Future<bool> isLoggedIn() async {
    try {
      LoggerUtil.i('🔍 로그인 상태 확인 중...');
      final isLoggedIn = await StorageService.isLoggedIn();
      LoggerUtil.i('✅ 로그인 상태: $isLoggedIn');
      return isLoggedIn;
    } catch (e) {
      LoggerUtil.e('❌ 로그인 상태 확인 중 오류 발생', e);
      return false;
    }
  }
}
