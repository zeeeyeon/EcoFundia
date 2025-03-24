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
      LoggerUtil.i('🔄 Google 토큰으로 로그인 시도');
      LoggerUtil.d('요청 URL: ${ApiService.apiEndpoints.login}');
      LoggerUtil.d(
          '요청 데이터: {"token": "${accessToken.substring(0, min(10, accessToken.length))}..."}');

      final response = await _apiService
          .post(ApiService.apiEndpoints.login, data: {'token': accessToken});

      LoggerUtil.i('✅ 서버 응답 코드: ${response.statusCode}');
      LoggerUtil.d('응답 데이터: ${response.data}');

      if (response.data == null) {
        throw AuthException('서버 응답이 올바르지 않습니다.');
      }

      final authResponse = AuthResponseModel.fromJson(response.data);
      LoggerUtil.d('파싱된 응답: $authResponse');

      // 인증 정보 저장
      if (authResponse.accessToken != null) {
        await StorageService.saveToken(authResponse.accessToken!);
        LoggerUtil.d('액세스 토큰 저장됨');
      }
      if (authResponse.refreshToken != null) {
        await StorageService.saveRefreshToken(authResponse.refreshToken!);
        LoggerUtil.d('리프레시 토큰 저장됨');
      }
      if (authResponse.user?.userId != null) {
        await StorageService.saveUserId(authResponse.user!.userId.toString());
        await StorageService.saveUserEmail(authResponse.user!.email);
        await StorageService.saveUserNickname(authResponse.user!.nickname);
        LoggerUtil.d('사용자 정보 저장됨');
      }

      return authResponse;
    } on DioException catch (e) {
      final statusCode = e.response?.statusCode;
      LoggerUtil.e('❌ API 오류 발생: $statusCode');
      LoggerUtil.d('에러 응답: ${e.response?.data}');
      LoggerUtil.d('에러 메시지: ${e.message}');

      switch (statusCode) {
        case 400:
          throw AuthException('잘못된 액세스 토큰입니다.', statusCode: 400);
        case 401:
          LoggerUtil.e('인증 실패 - 토큰이 유효하지 않거나 만료되었습니다.');
          throw AuthException('인증에 실패했습니다.', statusCode: 401);
        case 404:
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
        if (responseModel.user != null) {
          return responseModel.toEntity();
        } else {
          return const AuthResultEntity.newUser('회원가입이 필요합니다.');
        }
      } catch (e) {
        if (e is AuthException && e.statusCode == 404) {
          return AuthResultEntity.newUser(e.message);
        }
        rethrow;
      }
    } catch (e) {
      LoggerUtil.e('Google 로그인 실패', e);
      if (e is AuthException) {
        return AuthResultEntity.error(e.message, statusCode: e.statusCode);
      }
      return const AuthResultEntity.error('로그인 중 오류가 발생했습니다.');
    }
  }

  @override
  Future<AuthResultEntity> completeSignUp(SignUpEntity signUpData) async {
    try {
      // 도메인 엔티티를 데이터 모델로 변환
      final signUpModel = SignUpModel.fromEntity(signUpData);
      final userData = signUpModel.toJson();

      final response = await _apiService.post(
        ApiService.apiEndpoints.signup,
        data: userData,
      );

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
      // 오류가 발생해도 로컬 데이터는 지워야 함
      await StorageService.clearAll();
    }
  }

  @override
  Future<bool> isLoggedIn() async {
    try {
      return await StorageService.isAuthenticated();
    } catch (e) {
      LoggerUtil.e('로그인 상태 확인 실패', e);
      return false;
    }
  }

  @override
  Future<Map<String, dynamic>?> getGoogleUserInfo() async {
    try {
      final account =
          await _googleSignIn.signInSilently() ?? await _googleSignIn.signIn();
      if (account == null) return null;

      // 기본 정보 반환
      final userInfo = {
        'email': account.email,
        'name': account.displayName,
      };

      LoggerUtil.i('✅ Repository - Google 사용자 정보 획득 성공: $userInfo');
      return userInfo;
    } catch (e) {
      LoggerUtil.e('Google 사용자 정보 획득 실패', e);
      return null;
    }
  }
}
