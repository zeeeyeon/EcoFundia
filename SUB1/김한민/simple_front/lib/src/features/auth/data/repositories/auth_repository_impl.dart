import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../../domain/models/google_sign_in_result.dart';
import '../../domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  late final GoogleSignIn _googleSignIn;

  AuthRepositoryImpl() {
    if (kIsWeb) {
      _googleSignIn = GoogleSignIn(
        clientId:
            '609004819005-m2h2elam67hkc5f6r7oajvhpc5555du8.apps.googleusercontent.com',
        scopes: ['email', 'profile'],
      );
    } else {
      _googleSignIn = GoogleSignIn(
        scopes: ['email', 'profile'],
        serverClientId:
            '609004819005-h718agaqj9pgv1t7ja6sr8rq3n0ffeqv.apps.googleusercontent.com',
      );
    }
  }

  @override
  Future<GoogleSignInResult> getGoogleAuthCode() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) throw Exception('Google sign in cancelled');

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // 웹과 모바일 모두 accessToken을 사용
      final String? accessToken = googleAuth.accessToken;
      final String? serverAuthCode = googleAuth.serverAuthCode;

      if (accessToken == null) {
        throw Exception('Failed to get access token');
      }

      return GoogleSignInResult(
        accessToken: accessToken,
        serverAuthCode: serverAuthCode, // 모바일에서만 사용됨
        email: googleUser.email,
        name: googleUser.displayName,
      );
    } catch (e) {
      throw Exception('Failed to get Google auth code: $e');
    }
  }

  @override
  Future<bool> checkUserExists(String token) async {
    // TODO: 실제 백엔드 API 연동 시 구현
    // 현재는 테스트를 위해 항상 false 반환 (신규 회원으로 처리)
    return false;
  }
}
