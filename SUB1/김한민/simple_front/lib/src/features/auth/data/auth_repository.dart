import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:dio/dio.dart';
import '../domain/models/auth_response.dart';
import '../../../core/services/api_service.dart';
import '../../../core/services/storage_service.dart';

/// 인증 저장소 Provider
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(ApiService());
});

/// 인증 관련 작업을 처리하는 저장소
class AuthRepository {
  final ApiService _apiService;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email'],
  );

  AuthRepository(this._apiService);

  /// Google 로그인 진행 및 인가 코득
  Future<String?> getGoogleAuthCode() async {
    try {
      // Google 로그인 UI 표시
      final account = await _googleSignIn.signIn();
      if (account == null) {
        return null; // 사용자가 로그인 취소
      }

      // 인증 정보 획득
      final googleAuth = await account.authentication;
      return googleAuth.accessToken;
    } catch (e) {
      throw Exception('Google 로그인 중 오류가 발생했습니다: $e');
    }
  }

  /// 서버에 인가 코드 전송 및 JWT 획득
  Future<AuthResponse> authenticateWithGoogle(String authCode) async {
    try {
      final response =
          await _apiService.post('/auth/google', data: {'authCode': authCode});

      final authResponse = AuthResponse.fromJson(response.data);

      // JWT 토큰 저장
      if (authResponse.token != null) {
        await StorageService.saveToken(authResponse.token!);
      }

      // Refresh 토큰 저장
      if (authResponse.refreshToken != null) {
        await StorageService.saveRefreshToken(authResponse.refreshToken!);
      }

      // 사용자 ID 저장
      if (authResponse.userId != null) {
        await StorageService.saveUserId(authResponse.userId!);
      }

      return authResponse;
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception('서버를 찾을 수 없습니다.');
      } else if (e.response?.statusCode == 500) {
        throw Exception('서버 오류가 발생했습니다.');
      } else {
        throw Exception('인증 중 오류가 발생했습니다: ${e.message}');
      }
    } catch (e) {
      throw Exception('인증 중 오류가 발생했습니다: $e');
    }
  }

  /// 회원가입 완료 후 토큰 획득
  Future<AuthResponse> completeSignUp(Map<String, dynamic> userData) async {
    try {
      final response = await _apiService.post('/auth/signup', data: userData);

      final authResponse = AuthResponse.fromJson(response.data);

      // JWT 토큰 저장
      if (authResponse.token != null) {
        await StorageService.saveToken(authResponse.token!);
      }

      // Refresh 토큰 저장
      if (authResponse.refreshToken != null) {
        await StorageService.saveRefreshToken(authResponse.refreshToken!);
      }

      // 사용자 ID 저장
      if (authResponse.userId != null) {
        await StorageService.saveUserId(authResponse.userId!);
      }

      return authResponse;
    } catch (e) {
      throw Exception('회원가입 완료 중 오류가 발생했습니다: $e');
    }
  }

  /// 로그아웃
  Future<void> signOut() async {
    try {
      // Google 로그아웃
      await _googleSignIn.signOut();

      // 로컬 토큰 삭제
      await StorageService.clearUserData();

      // 서버에 로그아웃 알림 (선택적)
      await _apiService.post('/auth/logout');
    } catch (e) {
      // 로그아웃 실패 시 로컬 데이터만 삭제
      await StorageService.clearUserData();
    }
  }

  /// 로그인 상태 확인
  Future<bool> isLoggedIn() async {
    return await StorageService.isLoggedIn();
  }
}
