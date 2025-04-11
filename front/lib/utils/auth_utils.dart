import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/ui/widgets/login_required_modal.dart';
import '../core/providers/app_state_provider.dart';
import '../utils/logger_util.dart';

// Import the new provider
import 'package:front/core/providers/ui_providers.dart';

class AuthUtils {
  // static bool _isModalShowing = false; // Replaced with Riverpod state

  /// 권한 체크 후 필요시 모달 표시
  static Future<bool> checkAuthAndShowModal(
    BuildContext context,
    WidgetRef ref, {
    bool showModal = true,
  }) async {
    // Use a local variable to ensure atomicity within the function call
    bool wasModalShownInThisCall = false;
    try {
      // Use isLoggedInProvider directly from app_state_provider
      final isLoggedIn = ref.read(isLoggedInProvider);

      if (isLoggedIn) {
        // LoggerUtil.d('권한 체크 (isLoggedInProvider): 인증됨 (${feature.name})');
        LoggerUtil.d('권한 체크: 인증됨');
        return true;
      }

      // LoggerUtil.d('권한 체크 (isLoggedInProvider): 인증 필요 (${feature.name})');
      LoggerUtil.d('권한 체크: 인증 필요');

      // 모달 표시 로직 (Riverpod 상태 사용)
      if (showModal && context.mounted) {
        // Check the provider state *before* showing the dialog
        final isAlreadyShowing = ref.read(isLoginModalShowingProvider);
        if (!isAlreadyShowing) {
          // Set the provider state to true *before* await
          ref.read(isLoginModalShowingProvider.notifier).state = true;
          wasModalShownInThisCall =
              true; // Mark that this call initiated the modal

          await showDialog(
            context: context,
            barrierDismissible: true,
            builder: (context) => LoginRequiredModal(key: UniqueKey()),
          );
          // No need for finally block here, state is reset below
        }
      }

      // After potential modal interaction (or if modal wasn't shown),
      // re-check the login state.
      final isLoggedInAfterCheck = ref.read(isLoggedInProvider);
      return isLoggedInAfterCheck;
    } catch (e) {
      LoggerUtil.e('권한 체크 및 모달 표시 실패', e);
      return false; // Return false on error
    } finally {
      // Reset the provider state *only if* this specific function call initiated the modal showing.
      // This prevents premature state reset if multiple calls overlap.
      if (wasModalShownInThisCall) {
        // Check if provider is still true before setting to false
        // to avoid potential race conditions if another modal was opened quickly.
        if (ref.read(isLoginModalShowingProvider)) {
          ref.read(isLoginModalShowingProvider.notifier).state = false;
        }
      }
    }
  }

  // 라우트 권한 체크 - 현재 router.dart의 redirect 로직에서 처리하므로 주석 처리 또는 제거 고려
  /*
  static Future<String?> checkAuthForRoute(
    BuildContext context,
    Ref ref,
    GoRouterState state,
  ) async {
    // ... (기존 로직)
  }
  */

  // 로그인이 필요한 경로인지 확인 - 현재 router.dart의 requiresAuthPaths 리스트와 중복되므로 주석 처리 또는 제거 고려
  /*
  static bool isAuthRequiredPath(String path) {
    // ... (기존 로직)
  }
  */
}

// Removed helper providers from here as they cause conflicts or are unused:
// - isLoggedInProvider (use from app_state_provider.dart)
// - AuthRequiredFeature (remove if unused or move)
// - requiresAuthProvider (remove if unused or move)
// - isAuthenticatedProvider (remove as logic is simplified)
