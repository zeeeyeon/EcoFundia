import 'package:google_sign_in/google_sign_in.dart';
import 'package:dio/dio.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../../../core/services/api_service.dart';
import '../../../../core/services/storage_service.dart';
import '../../../../utils/logger_util.dart';
import 'package:front/features/auth/data/services/auth_service.dart';
import 'package:front/features/auth/data/models/sign_up_model.dart';
import 'package:front/core/exceptions/auth_exception.dart';
import 'package:front/features/auth/data/models/auth_response_model.dart';
import 'package:front/features/auth/domain/entities/auth_result_entity.dart';
import 'package:front/features/auth/domain/entities/sign_up_entity.dart';
import 'package:flutter/foundation.dart';

/// 인증 리포지토리 구현체
class AuthRepositoryImpl implements AuthRepository {
  final ApiService _apiService;
  final AuthService _authService;
  final GoogleSignIn _googleSignIn;

  AuthRepositoryImpl(this._apiService, this._authService)
      : _googleSignIn = _authService.googleSignIn;

  /// Google 로그인 액세스 토큰 획득 (내부 구현용)
  Future<String?> _getGoogleAccessToken() async {
    try {
      return await _authService.getGoogleAccessToken();
    } catch (e) {
      LoggerUtil.e('Google 로그인 실패', e);
      throw Exception('Google 로그인 중 오류가 발생했습니다: $e');
    }
  }

  /// Google 토큰으로 서버에 인증 요청 (내부 구현용)
  Future<AuthResponseModel> _authenticateWithGoogle(String accessToken) async {
    try {
      LoggerUtil.i('Google 토큰으로 로그인 시도');

      // 웹 환경에서는 CORS 문제로 인해 커스텀 헤더를 사용하지 않음
      const isWeb = kIsWeb;
      final options =
          isWeb ? null : Options(headers: {'X-Skip-Token-Refresh': 'true'});

      final response = await _apiService.post(
        ApiService.apiEndpoints.login,
        data: {'token': accessToken},
        options: options,
      );

      if (response.data == null) {
        throw AuthException('서버 응답이 올바르지 않습니다.');
      }

      return AuthResponseModel.fromJson(response.data);
    } on DioException catch (e) {
      final statusCode = e.response?.statusCode;
      var message = '인증 중 오류가 발생했습니다.';

      // 404 상태 코드인 경우 회원가입이 필요한지 확인
      if (statusCode == 404) {
        LoggerUtil.i('신규 회원: 회원가입이 필요합니다.');
        throw AuthException('회원가입이 필요합니다.', statusCode: 404, isNewUser: true);
      }

      switch (statusCode) {
        case 400:
          throw AuthException('잘못된 액세스 토큰입니다.', statusCode: 400);
        case 401:
          LoggerUtil.e('인증 실패 - 토큰이 유효하지 않거나 만료되었습니다.');
          throw AuthException('인증에 실패했습니다.', statusCode: 401);
        case 500:
          throw AuthException('서버 오류가 발생했습니다.', statusCode: 500);
        default:
          throw AuthException('인증 중 오류가 발생했습니다: ${e.message}');
      }
    } catch (e) {
      LoggerUtil.e('인증 실패', e);
      throw AuthException('인증 중 오류가 발생했습니다: $e');
    }
  }

  @override
  Future<AuthResultEntity> signInWithGoogle() async {
    try {
      final accessToken = await _getGoogleAccessToken();

      if (accessToken == null) {
        return const AuthResultEntity.cancelled();
      }

      try {
        final responseModel = await _authenticateWithGoogle(accessToken);

        // 로그인 성공 (사용자 정보가 있는 경우)
        if (responseModel.status.code == 'SU' && responseModel.user != null) {
          LoggerUtil.i('로그인 성공: ${responseModel.user?.email}');
          return responseModel.toEntity();
        } else {
          // 상태 코드가 SU이지만 사용자 정보가 없는 경우 (일어나지 않아야 함)
          LoggerUtil.w('로그인 성공했지만 사용자 정보가 없습니다.');
          return AuthResultEntity.newUser('회원가입이 필요합니다.', token: accessToken);
        }
      } catch (e) {
        if (e is AuthException && e.statusCode == 404 && e.isNewUser) {
          LoggerUtil.i('회원가입이 필요한 사용자: ${e.message}');
          return AuthResultEntity.newUser(e.message, token: accessToken);
        }
        rethrow;
      }
    } catch (e) {
      LoggerUtil.e('Google 로그인 실패', e);
      if (e is AuthException) {
        return AuthResultEntity.error(e.message, statusCode: e.statusCode);
      }
      return AuthResultEntity.error('로그인 중 오류가 발생했습니다: ${e.toString()}');
    }
  }

  @override
  Future<AuthResultEntity> completeSignUp(SignUpEntity signUpData) async {
    try {
      // 도메인 엔티티를 데이터 모델로 변환
      final signUpModel = SignUpModel.fromEntity(signUpData);
      final userData = signUpModel.toJson();

      LoggerUtil.d('회원가입 요청 데이터: $userData');

      final response = await _apiService.post(
        ApiService.apiEndpoints.signup,
        data: userData,
      );

      LoggerUtil.d('회원가입 응답 데이터: ${response.data}');

      if (response.data == null) {
        throw AuthException('서버 응답이 올바르지 않습니다.');
      }

      final authResponseModel = AuthResponseModel.fromJson(response.data);

      // 인증 정보 저장
      if (authResponseModel.accessToken != null) {
        await StorageService.saveToken(authResponseModel.accessToken!);
      }
      if (authResponseModel.refreshToken != null) {
        await StorageService.saveRefreshToken(authResponseModel.refreshToken!);
      }
      if (authResponseModel.user != null) {
        await StorageService.saveUserId(
            authResponseModel.user!.userId.toString());
        await StorageService.saveUserEmail(authResponseModel.user!.email);
        await StorageService.saveUserNickname(authResponseModel.user!.nickname);
      }

      // 모델을 엔티티로 변환하여 반환
      return authResponseModel.toEntity();
    } on DioException catch (e) {
      if (e.response?.statusCode == 201) {
        return AuthResponseModel.fromJson(e.response!.data).toEntity();
      }

      switch (e.response?.statusCode) {
        case 400:
          return const AuthResultEntity.error('회원가입 정보가 올바르지 않습니다.',
              statusCode: 400);
        case 409:
          return const AuthResultEntity.error('이미 존재하는 회원입니다.',
              statusCode: 409);
        case 500:
          return const AuthResultEntity.error('서버 오류가 발생했습니다.',
              statusCode: 500);
        default:
          return AuthResultEntity.error('회원가입 중 오류가 발생했습니다: ${e.message}');
      }
    } catch (e) {
      LoggerUtil.e('회원가입 실패', e);
      if (e is AuthException) {
        return AuthResultEntity.error(e.message, statusCode: e.statusCode);
      }
      return const AuthResultEntity.error('회원가입 완료 중 오류가 발생했습니다.');
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      await StorageService.clearAll();
    } catch (e) {
      LoggerUtil.e('로그아웃 실패', e);
      throw AuthException('로그아웃 중 오류가 발생했습니다: $e');
    }
  }

  @override
  Future<bool> isLoggedIn() async {
    try {
      final token = await StorageService.getToken();
      return token != null;
    } catch (e) {
      LoggerUtil.e('로그인 상태 확인 실패', e);
      return false;
    }
  }

  @override
  Future<Map<String, dynamic>?> getGoogleUserInfo() async {
    try {
      final currentUser = _googleSignIn.currentUser;
      if (currentUser == null) {
        return null;
      }

      return {
        'email': currentUser.email,
        'name': currentUser.displayName,
      };
    } catch (e) {
      LoggerUtil.e('Google 사용자 정보 획득 실패', e);
      return null;
    }
  }

  @override
  Future<AuthResponseModel> refreshToken(String refreshToken) async {
    try {
      final response = await _apiService.post(
        ApiService.apiEndpoints.reissue,
        data: {'refreshToken': refreshToken},
      );

      if (response.data == null) {
        throw AuthException('서버 응답이 올바르지 않습니다.');
      }

      return AuthResponseModel.fromJson(response.data);
    } on DioException catch (e) {
      LoggerUtil.e('토큰 갱신 실패', e);
      rethrow;
    } catch (e) {
      LoggerUtil.e('토큰 갱신 중 예외 발생', e);
      throw AuthException('토큰 갱신 중 오류가 발생했습니다: $e');
    }
  }
}
