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
      // 먼저 동기적인 Provider에서 로그인 상태 확인 (즉시 반응)
      final isLoggedIn = ref.read(isLoggedInProvider);
      final requiresAuth = ref.read(requiresAuthProvider(feature));

      // 인증이 필요하지 않은 기능이면 항상 true 반환
      if (!requiresAuth) return true;

      // 로그인되어 있으면 추가 체크 없이 바로 true 반환
      if (isLoggedIn) {
        LoggerUtil.d('권한 체크 (isLoggedInProvider): 인증됨 (${feature.name})');
        return true;
      }

      LoggerUtil.d('권한 체크 (isLoggedInProvider): 인증 필요 (${feature.name})');

      // 모달이 이미 표시 중이면 중복 표시 방지
      if (showModal && context.mounted && !_isModalShowing) {
        _isModalShowing = true;
        try {
          // 각 표시마다 고유한 키 생성
          final uniqueKey = UniqueKey();
          await showDialog(
            context: context,
            barrierDismissible: true, // 바깥 영역 터치로 닫기 가능
            builder: (context) => LoginRequiredModal(key: uniqueKey),
          );
        } finally {
          // 모달이 닫히면 상태 업데이트, finally로 예외 발생해도 항상 실행되게 함
          _isModalShowing = false;
        }

        // 모달 닫힌 후 로그인 상태 다시 확인 (모달에서 로그인했을 수 있음)
        return ref.read(isLoggedInProvider);
      }

      return false;
    } catch (e) {
      LoggerUtil.e('권한 체크 실패', e);
      // 오류 발생해도 모달 표시 상태 초기화
      _isModalShowing = false;
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
    final currentPath = state.uri.toString();
    if (!isAuthRequiredPath(currentPath)) return null;

    // 먼저 동기적인 Provider로 로그인 상태 확인 (즉시 상태 확인)
    final isLoggedIn = ref.read(isLoggedInProvider);

    if (isLoggedIn) {
      // 이미 로그인된 상태이면 다음 라우트로 진행
      return null;
    }

    // 로그인 상태가 아니면 추가로 토큰 유효성 확인 (더 안전한 검증)
    final isAuthenticated = await ref.read(isAuthenticatedProvider.future);

    // 앱 상태와 동기화
    if (isAuthenticated != isLoggedIn) {
      ref.read(appStateProvider.notifier).setLoggedIn(isAuthenticated);
      LoggerUtil.d('🔄 인증 상태 동기화: $isAuthenticated (라우트 체크)');
    }

    if (!isAuthenticated) {
      LoggerUtil.d('🔒 라우트 권한 체크: 인증 필요 ($currentPath) → 로그인 페이지로 리다이렉션');
      // 로그인 페이지로 리다이렉션
      return '/login';
    }

    return null;
  }

  /// 로그인이 필요한 경로인지 확인
  static bool isAuthRequiredPath(String path) {
    // URL 파라미터 제거 (예: /mypage?tab=1 -> /mypage)
    final cleanPath =
        path.contains('?') ? path.substring(0, path.indexOf('?')) : path;

    // 회원가입 관련 경로는 인증 불필요
    if (cleanPath == '/signup' || cleanPath == '/signup-complete') {
      return false;
    }

    const authRequiredPaths = {
      '/mypage': true,
      '/wishlist': true,
      '/profile-edit': true,
      '/my-funding': true,
      '/my-reviews': true,
      '/coupons': true,
      '/review': true, // /review/... 로 시작하는 모든 경로
      '/payment': true, // /payment/... 로 시작하는 모든 경로
    };

    // 정확한 경로 매칭 먼저 시도
    if (authRequiredPaths.containsKey(cleanPath)) {
      return authRequiredPaths[cleanPath]!;
    }

    // 부분 경로 매칭 (e.g., /review/123 -> /review로 매칭)
    for (final requiredPath in authRequiredPaths.keys) {
      if (cleanPath.startsWith(requiredPath) && requiredPath != '/') {
        return authRequiredPaths[requiredPath]!;
      }
    }

    return false;
  }
}
