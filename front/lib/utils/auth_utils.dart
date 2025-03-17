import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/ui/widgets/login_required_modal.dart';
import '../features/auth/ui/view_model/auth_provider.dart';
import '../features/auth/ui/view_model/auth_state_provider.dart';

class AuthUtils {
  static bool checkAuthAndShowModal(
    BuildContext context,
    WidgetRef ref,
    String feature,
  ) {
    final requiresAuth = ref.read(requiresAuthProvider(feature));
    final isAuthenticated = ref.read(isLoggedInProvider);

    if (requiresAuth && !isAuthenticated) {
      showDialog(
        context: context,
        builder: (context) => const LoginRequiredModal(),
      );
      return false;
    }
    return true;
  }
}
