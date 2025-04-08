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
  final GoogleSignIn _googleSignIn;

  AuthRepositoryImpl(this._apiService, AuthService authService)
      : _googleSignIn = authService.googleSignIn;

  /// Google 토큰으로 서버에 인증 요청 (내부 구현용)
  Future<AuthResponseModel> _authenticateWithGoogle(
      String accessToken, String email) async {
    try {
      final response = await _apiService.post(
        ApiService.apiEndpoints.login,
        data: {
          'token': accessToken,
        },
      );

      if (response.data == null) {
        throw AuthException('응답 데이터가 없습니다.');
      }

      final authResponseModel = AuthResponseModel.fromJson(response.data);

      if (authResponseModel.status.code == 404 &&
          authResponseModel.status.message ==
              "해당 이메일로 가입된 사용자가 없습니다. 회원가입이 필요합니다.") {
        throw AuthException(authResponseModel.status.message,
            statusCode: authResponseModel.status.code, isNewUser: true);
      }

      if (authResponseModel.status.code != 200) {
        throw AuthException(authResponseModel.status.message,
            statusCode: authResponseModel.status.code);
      }

      return authResponseModel;
    } on DioException catch (e) {
      LoggerUtil.e('Google 인증 실패: ${e.message}');
      throw AuthException(e.message ?? '인증 중 오류가 발생했습니다.',
          statusCode: e.response?.statusCode);
    }
  }

  @override
  Future<AuthResultEntity> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        return const AuthResultEntity.cancelled();
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      try {
        final response = await _authenticateWithGoogle(
          googleAuth.accessToken ?? '',
          googleUser.email,
        );
        return response.toEntity();
      } on AuthException catch (e) {
        if (e.isNewUser == true) {
          return AuthResultEntity.newUser(
            e.message,
            token: googleAuth.accessToken ?? '',
          );
        }
        rethrow;
      }
    } on AuthException catch (e) {
      LoggerUtil.e('Google 로그인 실패: ${e.message}');
      return AuthResultEntity.error(e.message, statusCode: e.statusCode);
    } catch (e) {
      LoggerUtil.e('Google 로그인 중 예상치 못한 오류 발생: $e');
      return const AuthResultEntity.error('로그인 중 오류가 발생했습니다.');
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

      // 회원가입 성공 (201)
      if (authResponseModel.status.code == 201) {
        // 인증 정보 저장
        if (authResponseModel.accessToken != null) {
          await StorageService.saveToken(authResponseModel.accessToken!);
        }
        if (authResponseModel.refreshToken != null) {
          await StorageService.saveRefreshToken(
              authResponseModel.refreshToken!);
        }
        if (authResponseModel.user != null) {
          await StorageService.saveUserId(
              authResponseModel.user!.userId.toString());
          await StorageService.saveUserEmail(authResponseModel.user!.email);
          await StorageService.saveUserNickname(
              authResponseModel.user!.nickname);
        }

        return authResponseModel.toEntity();
      }

      // 에러 처리
      return AuthResultEntity.error(
        authResponseModel.status.message,
        statusCode: authResponseModel.status.code,
      );
    } catch (e) {
      LoggerUtil.e('회원가입 실패', e);
      if (e is AuthException) {
        return AuthResultEntity.error(e.message, statusCode: e.statusCode);
      }
      return const AuthResultEntity.error('회원가입 완료 중 오류가 발생했습니다.');
    }
  }

  @override
  Future<void> signOut({CancelToken? cancelToken}) async {
    try {
      await _apiService.logout(cancelToken: cancelToken);
      LoggerUtil.i('✅ 서버 로그아웃 성공');

      // Google 로그아웃 (토큰이 필요하지 않음)
      await _googleSignIn.signOut();
      LoggerUtil.i('✅ Google 로그아웃 성공');

      // 로컬 스토리지 초기화 (마지막에 실행)
      await StorageService.clearAll();
      LoggerUtil.i('✅ 로컬 스토리지 초기화 완료');
    } catch (e) {
      // 요청 취소로 인한 오류는 무시
      if (e is DioException && e.type == DioExceptionType.cancel) {
        LoggerUtil.i('🛑 로그아웃 요청이 취소되었습니다.');
        await StorageService.clearAll(); // 로컬 스토리지는 초기화
        return; // 오류를 던지지 않음
      }

      LoggerUtil.e('❌ 로그아웃 실패', e);

      // 오류가 발생해도 로컬 스토리지는 초기화
      await StorageService.clearAll();

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
