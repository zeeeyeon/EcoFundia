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
  final GoogleSignIn _googleSignIn;

  AuthRepositoryImpl(this._apiService, AuthService authService)
      : _googleSignIn = authService.googleSignIn;

  /// Google 토큰으로 서버에 인증 요청 (내부 구현용)
  Future<AuthResponseModel> _authenticateWithGoogle(
      String accessToken, String email) async {
    try {
      LoggerUtil.d('서버 인증 요청: ${ApiService.apiEndpoints.login}, 이메일: $email');
      LoggerUtil.d('토큰 전송 - 토큰 길이: ${accessToken.length}');

      final response = await _apiService.post(
        ApiService.apiEndpoints.login,
        data: {
          'token': accessToken,
        },
      );

      if (response.data == null) {
        LoggerUtil.e('서버 응답 데이터가 없음');
        throw AuthException('응답 데이터가 없습니다.');
      }

      LoggerUtil.d('서버 응답 수신: ${response.statusCode}, 데이터: ${response.data}');

      // 500 에러가 발생한 경우 - 서버 측 오류
      if (response.statusCode == 500 ||
          (response.data['status'] != null &&
              response.data['status']['code'] == 500)) {
        final message = response.data['content'] != null
            ? '서버 오류: ${response.data['content']}'
            : '서버 내부 오류가 발생했습니다.';
        LoggerUtil.e('서버 500 오류: $message');
        throw AuthException(message, statusCode: 500);
      }

      // 응답 데이터로 모델 생성
      final authResponseModel = AuthResponseModel.fromJson(response.data);
      LoggerUtil.d(
          '응답 모델 변환: 상태 코드=${authResponseModel.status.code}, 메시지=${authResponseModel.status.message}');

      // 404: 사용자를 찾을 수 없음 - 회원가입 필요
      if (response.statusCode == 404 || authResponseModel.status.code == 404) {
        LoggerUtil.i('404 응답: ${authResponseModel.status.message}');

        // 특정 메시지 확인 - 회원가입 필요 여부
        if (authResponseModel.status.message.contains("가입된 사용자가 없습니다") ||
            authResponseModel.status.message.contains("회원가입이 필요합니다")) {
          LoggerUtil.i('회원가입이 필요한 사용자 감지: $email');
          throw AuthException(authResponseModel.status.message,
              statusCode: 404, isNewUser: true);
        }

        // 기타 404 에러
        throw AuthException(authResponseModel.status.message, statusCode: 404);
      }

      // 200 아닌 모든 상태 코드는 에러로 처리
      if (authResponseModel.status.code != 200) {
        LoggerUtil.e(
            '비정상 상태 코드: ${authResponseModel.status.code}, 메시지: ${authResponseModel.status.message}');
        throw AuthException(authResponseModel.status.message,
            statusCode: authResponseModel.status.code);
      }

      return authResponseModel;
    } on DioException catch (e) {
      LoggerUtil.e(
          'Google 인증 Dio 예외: ${e.message}, 상태 코드: ${e.response?.statusCode}');

      // 서버 측 오류 (500) 처리
      if (e.response?.statusCode == 500) {
        String errorMessage = '서버 내부 오류가 발생했습니다.';
        if (e.response?.data != null) {
          try {
            if (e.response!.data['content'] != null) {
              errorMessage = '서버 오류: ${e.response!.data['content']}';
            } else if (e.response!.data['status'] != null &&
                e.response!.data['status']['message'] != null) {
              errorMessage = e.response!.data['status']['message'];
            }
          } catch (parseError) {
            LoggerUtil.e('500 에러 응답 파싱 실패', parseError);
          }
        }
        LoggerUtil.e('서버 500 에러: $errorMessage');
        throw AuthException(errorMessage, statusCode: 500);
      }

      // Dio 예외가 발생했지만 응답이 있는 경우 (이제 500 이상 코드만 여기로 옴)
      if (e.response != null && e.response!.data != null) {
        try {
          final authResponseModel =
              AuthResponseModel.fromJson(e.response!.data);
          LoggerUtil.i(
              'Dio 예외에서 응답 데이터 복구: ${authResponseModel.status.message}');

          if (e.response!.statusCode == 404 &&
              authResponseModel.status.code == 404) {
            if (authResponseModel.status.message.contains("가입된 사용자가 없습니다") ||
                authResponseModel.status.message.contains("회원가입이 필요합니다")) {
              throw AuthException(authResponseModel.status.message,
                  statusCode: 404, isNewUser: true);
            }
          }

          throw AuthException(authResponseModel.status.message,
              statusCode: authResponseModel.status.code);
        } catch (parseError) {
          // 응답 데이터 파싱 실패
          if (parseError is! AuthException) {
            LoggerUtil.e('응답 데이터 파싱 실패', parseError);
          } else {
            rethrow;
          }
        }
      }

      throw AuthException(e.message ?? '인증 중 오류가 발생했습니다.',
          statusCode: e.response?.statusCode);
    } catch (e) {
      // AuthException은 그대로 전파
      if (e is AuthException) {
        LoggerUtil.e(
            '인증 예외 발생: ${e.message} (코드: ${e.statusCode}, 회원가입 필요: ${e.isNewUser})');
        rethrow;
      }

      // 기타 예외
      LoggerUtil.e('서버 인증 중 예상치 못한 예외 발생: $e');
      throw AuthException('인증 처리 중 오류가 발생했습니다.');
    }
  }

  @override
  Future<AuthResultEntity> signInWithGoogle() async {
    try {
      LoggerUtil.i('Google 로그인 시작');
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        LoggerUtil.i('Google 로그인 취소됨');
        return const AuthResultEntity.error('Google 로그인이 취소되었습니다.');
      }

      LoggerUtil.i('Google 계정 선택 완료: ${googleUser.email}');
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      if (googleAuth.accessToken == null) {
        LoggerUtil.e('Google 액세스 토큰 획득 실패');
        return const AuthResultEntity.error('Google 인증 토큰을 획득하지 못했습니다.');
      }

      final tokenLength = googleAuth.accessToken!.length;
      LoggerUtil.d('Google 인증 토큰 획득 성공: 토큰 길이=$tokenLength');
      LoggerUtil.d(
          '토큰 일부: ${googleAuth.accessToken!.substring(0, tokenLength > 10 ? 10 : tokenLength)}...');

      try {
        LoggerUtil.i('서버에 로그인 요청 시작');
        final response = await _authenticateWithGoogle(
          googleAuth.accessToken ?? '',
          googleUser.email,
        );

        LoggerUtil.d(
            '서버 응답 획득: 상태 코드=${response.status.code}, 메시지=${response.status.message}');

        // 404 상태 코드 및 특정 메시지 처리 - 회원가입 필요
        if (response.status.code == 404 &&
            response.status.message == "해당 이메일로 가입된 사용자가 없습니다. 회원가입이 필요합니다.") {
          LoggerUtil.i('회원가입이 필요한 사용자: ${googleUser.email}');
          return AuthResultEntity.newUser(
            "해당 이메일로 가입된 사용자가 없습니다. 회원가입이 필요합니다.",
            token: googleAuth.accessToken ?? '',
          );
        }

        // 정상 응답 처리
        LoggerUtil.i('로그인 성공: ${googleUser.email}');
        return response.toEntity();
      } on AuthException catch (authError) {
        LoggerUtil.e(
            '인증 예외 발생: ${authError.message} (코드: ${authError.statusCode})');

        // AuthException에서 isNewUser 플래그가 true인 경우 회원가입 필요
        if (authError.statusCode == 404 && authError.isNewUser) {
          LoggerUtil.i('회원가입이 필요: ${authError.message}');
          return AuthResultEntity.newUser(
            authError.message,
            token: googleAuth.accessToken ?? '',
          );
        }

        // 서버 측 오류 (500)
        if (authError.statusCode == 500) {
          LoggerUtil.e('서버 오류 발생: ${authError.message}');
          return AuthResultEntity.error('서버 오류: ${authError.message}',
              statusCode: 500);
        }

        return AuthResultEntity.error(authError.message,
            statusCode: authError.statusCode);
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
