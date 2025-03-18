import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:front/core/services/api_service.dart';
import 'package:front/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:front/features/auth/domain/models/auth_state.dart';
import 'package:front/features/auth/domain/repositories/auth_repository.dart';
import 'package:front/features/auth/domain/use_cases/google_sign_in_use_case.dart';
import 'package:front/features/auth/ui/view_model/auth_view_model.dart';

/// Auth Repository Provider
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final apiService = ApiService();
  return AuthRepositoryImpl(apiService);
});

/// UseCase Provider들
final googleSignInUseCaseProvider = Provider<GoogleSignInUseCase>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return GoogleSignInUseCase(repository);
});

final completeSignUpUseCaseProvider = Provider<CompleteSignUpUseCase>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return CompleteSignUpUseCase(repository);
});

final signOutUseCaseProvider = Provider<SignOutUseCase>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return SignOutUseCase(repository);
});

final checkLoginStatusUseCaseProvider =
    Provider<CheckLoginStatusUseCase>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return CheckLoginStatusUseCase(repository);
});

/// 인증 ViewModel Provider
final authProvider = StateNotifierProvider<AuthViewModel, AuthState>((ref) {
  return AuthViewModel(
    googleSignInUseCase: ref.watch(googleSignInUseCaseProvider),
    signOutUseCase: ref.watch(signOutUseCaseProvider),
    checkLoginStatusUseCase: ref.watch(checkLoginStatusUseCaseProvider),
  );
});

/// 로그인 상태 Provider
final isLoggedInProvider = Provider<bool>((ref) {
  return ref.watch(authProvider).isLoggedIn;
});

/// 신규 회원 여부 Provider
final isNewUserProvider = Provider<bool>((ref) {
  return ref.watch(authProvider).isNewUser;
});

/// 상태 초기화 Provider
/// 페이지 전환 시 상태를 초기화하려면 이 Provider를 watch하세요
final authStateResetProvider = Provider<void>((ref) {
  ref.onDispose(() {
    // 컴포넌트가 dispose될 때 상태 초기화
    ref.read(authProvider.notifier).resetState();
  });
});
