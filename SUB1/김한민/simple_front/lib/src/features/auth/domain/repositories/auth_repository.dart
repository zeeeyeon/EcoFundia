import '../models/google_sign_in_result.dart';

abstract class AuthRepository {
  Future<GoogleSignInResult> getGoogleAuthCode();
  Future<bool> checkUserExists(String token);
}
