import 'package:google_sign_in/google_sign_in.dart';
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
      return await _authService.getGoogleAccessToken();
    } catch (e) {
      LoggerUtil.e('Google 로그인 실패', e);
      throw Exception('Google 로그인 중 오류가 발생했습니다: $e');
    }
  }

  @override
  Future<AuthResponse> authenticateWithGoogle(String accessToken) async {
    try {
      final response = await _apiService
          .post(ApiService.apiEndpoints.login, data: {'token': accessToken});

      if (response.data == null) {
        throw AuthException('서버 응답이 올바르지 않습니다.');
      }

      final authResponse = AuthResponse.fromJson(response.data);

      if (authResponse.accessToken != null) {
        await StorageService.saveToken(authResponse.accessToken!);
      }
      if (authResponse.refreshToken != null) {
        await StorageService.saveRefreshToken(authResponse.refreshToken!);
      }
      if (authResponse.user?.userId != null) {
        await StorageService.saveUserId(authResponse.user!.userId.toString());
      }

      return authResponse;
    } on DioException catch (e) {
      final statusCode = e.response?.statusCode;

      switch (statusCode) {
        case 400:
          throw AuthException('잘못된 액세스 토큰입니다.', statusCode: 400);
        case 401:
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
  Future<AuthResponse> completeSignUp(SignUpModel signUpData) async {
    try {
      final userData = signUpData.toJson();
      final response = await _apiService.post(ApiService.apiEndpoints.signup,
          data: userData);

      if (response.data == null) {
        throw AuthException('서버 응답이 올바르지 않습니다.');
      }

      final authResponse = AuthResponse.fromJson(response.data);

      if (authResponse.accessToken != null) {
        await StorageService.saveToken(authResponse.accessToken!);
      }
      if (authResponse.refreshToken != null) {
        await StorageService.saveRefreshToken(authResponse.refreshToken!);
      }
      if (authResponse.user != null) {
        await StorageService.saveUserId(authResponse.user!.userId.toString());
        await StorageService.saveUserEmail(authResponse.user!.email);
        await StorageService.saveUserNickname(authResponse.user!.nickname);
      }

      return authResponse;
    } on DioException catch (e) {
      if (e.response?.statusCode == 201) {
        return AuthResponse.fromJson(e.response!.data);
      }

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
      LoggerUtil.e('회원가입 실패', e);
      if (e is AuthException) rethrow;
      throw AuthException('회원가입 완료 중 오류가 발생했습니다: $e');
    }
  }

  @override
  Future<AuthResponse> completeSignUpWithMap(
      Map<String, dynamic> userData) async {
    try {
      if (!userData.containsKey('email') ||
          !userData.containsKey('nickname') ||
          !userData.containsKey('gender') ||
          !userData.containsKey('age')) {
        throw AuthException('필수 회원정보가 누락되었습니다.');
      }

      final signUpModel = SignUpModel(
        email: userData['email'] as String,
        nickname: userData['nickname'] as String,
        gender: userData['gender'] as String,
        age: userData['age'] as int,
        token: userData['token'] as String?,
      );

      return await completeSignUp(signUpModel);
    } catch (e) {
      LoggerUtil.e('회원가입 실패', e);
      if (e is AuthException) rethrow;
      throw AuthException('회원가입 완료 중 오류가 발생했습니다: $e');
    }
  }

  @override
  Future<void> signOut() async {
    await StorageService.clearAll();
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
  Future<bool> checkLoginStatus() => isLoggedIn();

  @override
  Future<AuthResult> signInWithGoogle() async {
    try {
      final accessToken = await getGoogleAccessToken();

      if (accessToken == null) {
        return const AuthResult.cancelled();
      }

      try {
        final response = await _authService.authenticateWithGoogle(accessToken);
        if (response.user != null) {
          return AuthResult.success(response);
        } else {
          return const AuthResult.newUser('회원가입이 필요합니다.');
        }
      } catch (e) {
        if (e is AuthException && e.statusCode == 404) {
          return AuthResult.newUser(e.message);
        }
        rethrow;
      }
    } catch (e) {
      LoggerUtil.e('Google 로그인 실패', e);
      if (e is AuthException) {
        return AuthResult.error(e.message, statusCode: e.statusCode);
      }
      return const AuthResult.error('로그인 중 오류가 발생했습니다.');
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
