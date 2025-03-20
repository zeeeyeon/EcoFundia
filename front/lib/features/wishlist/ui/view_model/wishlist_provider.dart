import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:front/features/wishlist/data/repositories/wishlist_repository_impl.dart';
import 'package:front/features/wishlist/domain/repositories/wishlist_repository.dart';
import 'package:front/features/wishlist/ui/view_model/wishlist_view_model.dart';

/// 위시리스트 레포지토리 프로바이더 재정의
/// 레포지토리 구현체를 주입
final wishlistRepositoryProvider = Provider<WishlistRepository>((ref) {
  return WishlistRepositoryImpl();
});
