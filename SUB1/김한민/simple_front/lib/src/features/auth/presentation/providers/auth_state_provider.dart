import 'package:flutter_riverpod/flutter_riverpod.dart';

final isAuthenticatedProvider = StateProvider<bool>((ref) => false);

final requiresAuthProvider = Provider.family<bool, String>((ref, feature) {
  // 로그인이 필요한 기능들을 정의
  const authRequiredFeatures = {
    'purchase': true, // 구매
    'like': true, // 좋아요
    'mypage': true, // 마이페이지
    'wishlist': true, // 찜 목록
  };

  return authRequiredFeatures[feature] ?? false;
});
