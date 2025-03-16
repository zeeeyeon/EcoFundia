import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/models/google_sign_in_result.dart';
import '../../domain/repositories/auth_repository.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl();
});

final authStateProvider =
    StateNotifierProvider<AuthNotifier, AsyncValue<GoogleSignInResult?>>((ref) {
  return AuthNotifier(ref.watch(authRepositoryProvider));
});

class AuthNotifier extends StateNotifier<AsyncValue<GoogleSignInResult?>> {
  final AuthRepository _authRepository;

  AuthNotifier(this._authRepository) : super(const AsyncValue.data(null));

  Future<GoogleSignInResult> signInWithGoogle() async {
    try {
      state = const AsyncValue.loading();

      // 구글 인증 코드 받기
      final result = await _authRepository.getGoogleAuthCode();
      state = AsyncValue.data(result);
      return result;
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }
}
