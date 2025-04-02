import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/ui/widgets/login_required_modal.dart';
import '../core/providers/app_state_provider.dart';
import '../utils/logger_util.dart';
import 'package:go_router/go_router.dart';

class AuthUtils {
  // 모달 표시 상태를 추적하는 정적 변수
  static bool _isModalShowing = false;

  /// 권한 체크 후 필요시 모달 표시
  static Future<bool> checkAuthAndShowModal(
    BuildContext context,
    WidgetRef ref,
    AuthRequiredFeature feature, {
    bool showModal = true,
  }) async {
    try {
      final isAuthenticated = await ref.read(isAuthenticatedProvider.future);
      final requiresAuth = ref.read(requiresAuthProvider(feature));

      if (!requiresAuth) return true;

      if (!isAuthenticated) {
        LoggerUtil.d('권한 체크: 인증 필요 (${feature.name})');

        // 모달이 이미 표시 중이면 중복 표시 방지
        if (showModal && context.mounted && !_isModalShowing) {
          _isModalShowing = true;
          await showDialog(
            context: context,
            builder: (context) => const LoginRequiredModal(),
          ).then((_) {
            // 모달이 닫히면 상태 업데이트
            _isModalShowing = false;
          });
        }
        return false;
      }

      return true;
    } catch (e) {
      LoggerUtil.e('권한 체크 실패', e);
      return false;
    }
  }

  /// 라우트 권한 체크
  static Future<String?> checkAuthForRoute(
    BuildContext context,
    Ref ref,
    GoRouterState state,
  ) async {
    // 현재 경로가 로그인이 필요한 경로인지 확인
    if (!isAuthRequiredPath(state.uri.toString())) return null;

    final isAuthenticated = await ref.read(isAuthenticatedProvider.future);
    if (!isAuthenticated) {
      LoggerUtil.d('라우트 권한 체크: 인증 필요 (${state.uri.toString()})');
      return '/login';
    }

    return null;
  }

  /// 로그인이 필요한 경로인지 확인
  static bool isAuthRequiredPath(String path) {
    const authRequiredPaths = {
      '/mypage': true,
      '/wishlist': true, // 위시리스트 권한 체크 해제
    };
    return authRequiredPaths[path] ?? false;
  }
}
