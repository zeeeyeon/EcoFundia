import 'package:go_router/go_router.dart';
import 'package:front/core/ui/page/coming_soon_screen.dart';
import 'package:front/features/home/ui/pages/project_detail_screen.dart';
import 'package:front/shared/seller/ui/pages/seller_detail_screen.dart';
import 'package:front/shared/payment/ui/pages/payment_page.dart';
import 'package:front/shared/payment/ui/pages/payment_complete_page.dart';

// 공통 또는 최상위 레벨 라우트 목록
final List<RouteBase> commonRoutes = [
  // 프로젝트 상세 페이지
  GoRoute(
    path: '/project/:id',
    builder: (context, state) {
      final projectId = int.parse(state.pathParameters['id'] ?? '1');
      return ProjectDetailScreen(projectId: projectId);
    },
  ),
  // 판매자 상세 페이지
  GoRoute(
    path: '/seller/:id',
    builder: (context, state) {
      final sellerId = int.parse(state.pathParameters['id'] ?? '1');
      return SellerDetailScreen(sellerId: sellerId);
    },
  ),
  // 결제 완료 페이지
  GoRoute(
    path: '/payment/complete',
    name: 'payment-complete',
    builder: (context, state) {
      return const PaymentCompletePage();
    },
  ),
  // 결제 페이지
  GoRoute(
    path: '/payment/:productId',
    name: 'payment',
    builder: (context, state) {
      final productId = state.pathParameters['productId'] ?? '';
      return PaymentPage(productId: productId);
    },
  ),
  // Coming Soon Page (Fallback)
  GoRoute(
    path: '/coming-soon',
    builder: (context, state) => const ComingSoonScreen(),
  ),
];
