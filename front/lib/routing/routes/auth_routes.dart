import 'package:go_router/go_router.dart';
import 'package:front/features/auth/ui/pages/login_screen.dart';
import 'package:front/features/auth/ui/pages/sign_up_screen.dart';
import 'package:front/features/auth/ui/pages/signup_complete_screen.dart';
import 'package:front/features/splash/ui/pages/splash_screen.dart';

// 인증 관련 최상위 라우트 목록
final List<RouteBase> authRoutes = [
  GoRoute(
    path: '/login',
    builder: (context, state) => const LoginScreen(),
  ),
  GoRoute(
    path: '/signup',
    name: 'signup',
    builder: (context, state) {
      final extras = state.extra as Map<String, dynamic>?;
      return SignUpScreen(
        name: extras?['name'],
        email: extras?['email'] ?? '',
        token: extras?['token'],
      );
    },
  ),
  GoRoute(
    path: '/signup-complete',
    name: 'signup-complete',
    builder: (context, state) {
      final extras = state.extra as Map<String, dynamic>?;
      return SignupCompleteScreen(nickname: extras?['nickname'] ?? '');
    },
  ),
  GoRoute(
    path: '/splash',
    builder: (context, state) => const SplashPage(),
  ),
];
