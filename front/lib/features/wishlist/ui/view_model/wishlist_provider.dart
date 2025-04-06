import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:front/features/wishlist/data/repositories/wishlist_repository_impl.dart';
import 'package:front/features/wishlist/domain/repositories/wishlist_repository.dart';
import 'package:front/features/wishlist/domain/use_cases/get_active_wishlist_items_use_case.dart';
import 'package:front/features/wishlist/domain/use_cases/get_ended_wishlist_items_use_case.dart';
import 'package:front/features/wishlist/domain/use_cases/get_wishlist_ids_use_case.dart';
import 'package:front/features/wishlist/domain/use_cases/toggle_wishlist_item_use_case.dart';
import 'package:front/features/wishlist/ui/view_model/wishlist_view_model.dart';
import 'package:front/utils/logger_util.dart';
import 'dart:async'; // TimeoutException을 위한 import 추가

/// 위시리스트 레포지토리 프로바이더 재정의
/// 레포지토리 구현체를 주입
final wishlistRepositoryProvider = Provider<WishlistRepository>((ref) {
  final wishlistService = ref.watch(wishlistServiceProvider);
  return WishlistRepositoryImpl(wishlistService: wishlistService);
});

/// 위시리스트 ID 목록 Provider (전역 상태)
final wishlistIdsProvider = StateProvider<Set<int>>((ref) => <int>{});

/// GetWishlistIdsUseCase Provider
final getWishlistIdsUseCaseProvider = Provider<GetWishlistIdsUseCase>((ref) {
  final repository = ref.watch(wishlistRepositoryProvider);
  return GetWishlistIdsUseCase(repository);
});

/// 위시리스트 ID 로딩 함수 Provider
final loadWishlistIdsProvider = Provider<Future<void> Function()>((ref) {
  return () async {
    try {
      LoggerUtil.i('🔄 위시리스트 ID 목록 로딩 시작');

      // 기존 위시리스트 ID 상태 백업 (에러 시 복원용)
      final originalIds = Set<int>.from(ref.read(wishlistIdsProvider));

      // 로딩 시작 전에 재시도 횟수 제한 변수 설정
      int retryCount = 0;
      const maxRetries = 2; // 최대 재시도 횟수

      while (retryCount <= maxRetries) {
        try {
          // 요청에 타임아웃 적용
          final useCase = ref.read(getWishlistIdsUseCaseProvider);
          final ids = await useCase.execute().timeout(
            const Duration(seconds: 5),
            onTimeout: () {
              LoggerUtil.w('⚠️ 위시리스트 ID 목록 로딩 타임아웃');
              throw TimeoutException('위시리스트 ID 로딩 타임아웃');
            },
          );

          LoggerUtil.i('✅ 위시리스트 ID 목록 로딩 완료: ${ids.length}개');

          if (ids.isNotEmpty) {
            // ID 목록 상세 로깅
            LoggerUtil.d('📋 위시리스트 ID 목록: $ids');
          } else {
            LoggerUtil.d('📋 위시리스트 ID 목록이 비어있습니다');
          }

          // StateProvider 업데이트
          ref.read(wishlistIdsProvider.notifier).state = ids.toSet();
          return; // 성공하면 함수 종료
        } on TimeoutException {
          retryCount++;
          if (retryCount <= maxRetries) {
            LoggerUtil.w('🔄 위시리스트 ID 로딩 타임아웃, $retryCount번째 재시도 중...');
            await Future.delayed(const Duration(seconds: 1)); // 잠시 대기 후 재시도
          } else {
            LoggerUtil.e('❌ 위시리스트 ID 로딩 타임아웃 최대 재시도 횟수 초과');
            // 최대 재시도 횟수 초과 시 백업 상태 복원 (기존 상태 유지)
            ref.read(wishlistIdsProvider.notifier).state = originalIds;
            return;
          }
        } on Exception catch (e) {
          LoggerUtil.e('❌ 위시리스트 ID 로딩 실패', e);
          // 예외 발생 시 재시도하지 않고 종료
          // 기존 상태 복원 (상태를 날리지 않음)
          ref.read(wishlistIdsProvider.notifier).state = originalIds;
          return;
        }
      }
    } on Exception catch (e) {
      LoggerUtil.e('❌ 위시리스트 ID 목록 로딩 실패 (최외곽 예외)', e);
      // 오류가 발생해도 상태를 초기화하지 않고 그대로 유지
      // 이미 정상적으로 로드된 위시리스트 ID가 있다면 그대로 유지
    } catch (e) {
      LoggerUtil.e('❌ 위시리스트 ID 목록 로딩 중 예상하지 못한 오류', e);
      // 오류가 발생해도 상태를 초기화하지 않고 그대로 유지
    }
  };
});
