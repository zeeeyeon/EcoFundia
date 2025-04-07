import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:front/features/auth/domain/entities/auth_state.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:front/core/services/api_service.dart';
import 'package:front/core/constants/auth_constants.dart';
import 'package:front/core/providers/app_state_provider.dart';
import 'package:front/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:front/features/auth/data/services/auth_service.dart';
import 'package:front/features/auth/domain/repositories/auth_repository.dart';
import 'package:front/features/auth/domain/use_cases/google_sign_in_use_case.dart';
import 'package:front/features/auth/domain/use_cases/complete_sign_up_use_case.dart';
import 'package:front/features/auth/domain/use_cases/sign_out_use_case.dart';
import 'package:front/features/auth/domain/use_cases/check_login_status_use_case.dart';
import 'package:front/features/auth/ui/view_model/auth_view_model.dart';
import 'package:front/routing/router.dart';

/// Auth Service Provider
final authServiceProvider = Provider<AuthService>((ref) {
  // 웹과 모바일 환경에 맞게 GoogleSignIn 설정
  final googleSignIn = kIsWeb
      ? GoogleSignIn(
          scopes: ['email', 'profile'],
          clientId: AuthConstants.webClientId,
        )
      : GoogleSignIn(
          scopes: ['email', 'profile'],
          serverClientId: AuthConstants.serverClientId,
        );

  // ApiService 주입 (중앙화된 Dio 인스턴스 사용)
  final apiService = ref.watch(apiServiceProvider);

  return AuthService(
    apiService: apiService,
    googleSignIn: googleSignIn,
  );
});

/// Auth Repository Provider
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  final authService = ref.watch(authServiceProvider);
  return AuthRepositoryImpl(apiService, authService);
});

/// UseCase Provider들
final googleSignInUseCaseProvider = Provider<GoogleSignInUseCase>((ref) {
  return GoogleSignInUseCase(ref.watch(authRepositoryProvider));
});

final completeSignUpUseCaseProvider = Provider<CompleteSignUpUseCase>((ref) {
  return CompleteSignUpUseCase(ref.watch(authRepositoryProvider));
});

final signOutUseCaseProvider = Provider<SignOutUseCase>((ref) {
  return SignOutUseCase(ref.watch(authRepositoryProvider));
});

final checkLoginStatusUseCaseProvider =
    Provider<CheckLoginStatusUseCase>((ref) {
  return CheckLoginStatusUseCase(ref.watch(authRepositoryProvider));
});

/// Auth ViewModel Provider
final authProvider = StateNotifierProvider<AuthViewModel, AuthState>((ref) {
  final router = ref.watch(routerProvider);
  return AuthViewModel(
    ref: ref,
    appStateViewModel: ref.watch(appStateProvider.notifier),
    authRepository: ref.watch(authRepositoryProvider),
    checkLoginStatusUseCase: ref.watch(checkLoginStatusUseCaseProvider),
    googleSignInUseCase: ref.watch(googleSignInUseCaseProvider),
    signOutUseCase: ref.watch(signOutUseCaseProvider),
    router: router,
  );
});

/// 상태 초기화 Provider
/// 페이지 전환 시 상태를 초기화하려면 이 Provider를 watch하세요
final authStateResetProvider = Provider<void>((ref) {
  ref.onDispose(() {
    // 컴포넌트가 dispose될 때 상태 초기화
    ref.read(authProvider.notifier).resetState();
  });
});
