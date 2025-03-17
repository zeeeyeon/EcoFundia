import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/login_required_modal.dart';
import '../../features/auth/presentation/providers/auth_state_provider.dart';

class AuthUtils {
  static bool checkAuthAndShowModal(
    BuildContext context,
    WidgetRef ref,
    String feature,
  ) {
    final requiresAuth = ref.read(requiresAuthProvider(feature));
    final isAuthenticated = ref.read(isAuthenticatedProvider);

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
