import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/api_service.dart';
import '../../data/auth_repository.dart';
import '../../domain/models/auth_state.dart';
import '../notifiers/auth_notifier.dart';

/// Auth Repository Provider
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(ApiService());
});

/// 인증 Provider
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  return AuthNotifier(authRepository);
});

/// 로그인 상태 Provider
final isLoggedInProvider = Provider<bool>((ref) {
  return ref.watch(authProvider).isLoggedIn;
});

/// 신규 회원 여부 Provider
final isNewUserProvider = Provider<bool>((ref) {
  return ref.watch(authProvider).isNewUser;
});
