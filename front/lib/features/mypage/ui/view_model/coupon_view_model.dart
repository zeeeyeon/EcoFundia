import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:front/core/providers/app_state_provider.dart';
import 'package:front/features/mypage/data/repositories/coupon_repository_impl.dart';
import 'package:front/features/mypage/domain/entities/coupon_apply_result.dart';
import 'package:front/features/mypage/domain/use_cases/apply_coupon_use_case.dart';
import 'package:front/features/mypage/domain/use_cases/get_coupon_count_use_case.dart';
import 'package:front/features/mypage/domain/use_cases/get_coupon_list_use_case.dart';
import 'package:front/utils/logger_util.dart';
import 'package:front/features/mypage/ui/model/coupon_state.dart';
import 'package:front/utils/error_handling_mixin.dart';
import 'dart:async' show unawaited;

// 쿠폰 관련 UseCase Provider들
final getCouponCountUseCaseProvider = Provider<GetCouponCountUseCase>((ref) {
  final repository = ref.watch(couponRepositoryProvider);
  return GetCouponCountUseCase(repository);
});

final getCouponListUseCaseProvider = Provider<GetCouponListUseCase>((ref) {
  final repository = ref.watch(couponRepositoryProvider);
  return GetCouponListUseCase(repository);
});

final applyCouponUseCaseProvider = Provider<ApplyCouponUseCase>((ref) {
  final repository = ref.watch(couponRepositoryProvider);
  return ApplyCouponUseCase(repository);
});

/// 쿠폰 개수 로딩을 위한 FutureProvider
final couponCountProvider = FutureProvider.autoDispose((ref) async {
  final useCase = ref.watch(getCouponCountUseCaseProvider);
  final count = await useCase.execute();
  return count;
});

/// 쿠폰 목록 로딩을 위한 FutureProvider
final couponListProvider = FutureProvider.autoDispose((ref) async {
  final useCase = ref.watch(getCouponListUseCaseProvider);
  final coupons = await useCase.execute();
  return coupons;
});

/// 쿠폰 관련 이벤트
enum CouponModalEvent {
  none,
  success,
  alreadyIssued,
  needLogin,
  error,
  timeLimit,
}

/// 쿠폰 ViewModel
class CouponViewModel extends StateNotifier<CouponState>
    with StateNotifierErrorHandlingMixin {
  final GetCouponCountUseCase _getCouponCountUseCase;
  final GetCouponListUseCase _getCouponListUseCase;
  final ApplyCouponUseCase _applyCouponUseCase;
  final Ref _ref;

  // 캐시 관련 변수
  DateTime? _lastCountLoadTime;
  DateTime? _lastListLoadTime;
  static const int _cacheValidSeconds = 30;

  // 중복 요청 방지를 위한 플래그
  bool _isLoadingCount = false;
  bool _isLoadingList = false;
  bool _isApplyingCoupon = false;

  CouponViewModel({
    required GetCouponCountUseCase getCouponCountUseCase,
    required GetCouponListUseCase getCouponListUseCase,
    required ApplyCouponUseCase applyCouponUseCase,
    required Ref ref,
  })  : _getCouponCountUseCase = getCouponCountUseCase,
        _getCouponListUseCase = getCouponListUseCase,
        _applyCouponUseCase = applyCouponUseCase,
        _ref = ref,
        super(CouponState.initial());

  // 캐시 유효성 검사
  bool _isCacheValid(DateTime? lastLoadTime) {
    if (lastLoadTime == null) return false;
    final difference = DateTime.now().difference(lastLoadTime).inSeconds;
    LoggerUtil.d(
        '🎫 캐시 확인: 마지막 로드로부터 $difference초 경과 (유효시간: $_cacheValidSeconds초)');
    return difference < _cacheValidSeconds;
  }

  /// 에러 처리 후 상태 업데이트
  void _handleError(dynamic error,
      {bool isLoading = false, bool isApplying = false}) {
    setErrorState(error);

    // 상태 업데이트를 위젯 트리 빌드 중에 수행하면 오류 발생
    // 비동기 작업이 완료된 후 상태를 업데이트하도록 Future microtask 사용
    // 경고 방지를 위해 unawaited 식별자 추가
    unawaited(Future.microtask(() {
      if (mounted) {
        state = state.copyWith(
          isLoading: isLoading,
          isApplying: isApplying,
          errorMessage: errorMessage,
          isNetworkError: isNetworkError,
        );

        if (error is CouponException &&
            error.type == CouponErrorType.unauthorized) {
          setModalEvent(CouponModalEvent.needLogin);
        }
      }
    }));
  }

  /// 쿠폰 개수 로드
  Future<void> loadCouponCount({bool forceRefresh = false}) async {
    // 중복 요청 방지
    if (_isLoadingCount && !forceRefresh) {
      LoggerUtil.d('🎫 쿠폰 개수 로드 중복 요청 방지');
      return;
    }

    // 캐시 유효성 검사
    if (!forceRefresh && _isCacheValid(_lastCountLoadTime)) {
      LoggerUtil.d('🎫 캐시된 쿠폰 개수 사용: ${state.couponCount}');
      return;
    }

    try {
      _isLoadingCount = true;
      // 안전하게 상태 업데이트 (Future microtask 사용)
      unawaited(Future.microtask(() {
        if (mounted) {
          state = state.copyWith(isLoading: true);
          startLoading();
        }
      }));

      final count = await _getCouponCountUseCase.execute();
      _lastCountLoadTime = DateTime.now();

      // 안전하게 상태 업데이트 (Future microtask 사용)
      unawaited(Future.microtask(() {
        if (mounted) {
          state = state.copyWith(
            couponCount: count,
            isLoading: false,
            lastUpdated: _lastCountLoadTime,
            errorMessage: '',
          );
          finishLoading();
        }
      }));

      LoggerUtil.d('🎫 쿠폰 개수 로드 성공: $count');
    } catch (e) {
      _handleError(e);
      finishLoading();
      LoggerUtil.e('🎫 쿠폰 개수 로드 실패', e);
    } finally {
      _isLoadingCount = false;
    }
  }

  /// 쿠폰 발급
  Future<bool> applyCoupon() async {
    // 선제적 로그인 확인
    final isLoggedIn = _ref.read(isLoggedInProvider);
    if (!isLoggedIn) {
      LoggerUtil.w('🎫 쿠폰 발급 시도: 로그인이 필요합니다.');
      setModalEvent(CouponModalEvent.needLogin);
      return false;
    }

    // 중복 요청 방지
    if (_isApplyingCoupon) {
      LoggerUtil.d('🎫 이미 쿠폰 발급 처리 중');
      return false;
    }

    try {
      _isApplyingCoupon = true;

      // 안전하게 상태 업데이트 (Future microtask 사용)
      unawaited(Future.microtask(() {
        if (mounted) {
          state = state.copyWith(
            isApplying: true,
            errorMessage: '',
            modalEvent: CouponModalEvent.none,
          );
        }
      }));

      final result = await _applyCouponUseCase.execute();

      return switch (result) {
        CouponApplySuccess() => await _handleSuccess(),
        AlreadyIssuedFailure() => _handleAlreadyIssued(result),
        AuthorizationFailure() => _handleAuthorizationFailure(result),
        CouponTimeLimitFailure() => _handleTimeLimitFailure(result),
        CouponApplyFailure() => _handleFailure(result),
      };
    } catch (e) {
      _handleError(e, isApplying: false);
      LoggerUtil.e('🎫 쿠폰 발급 중 예외 발생', e);
      return false;
    } finally {
      _isApplyingCoupon = false;
    }
  }

  /// 쿠폰 목록 로드
  Future<void> loadCouponList() async {
    // 중복 요청 방지
    if (_isLoadingList) {
      LoggerUtil.d('🎫 쿠폰 목록 로드 스킵: 이미 로딩 중');
      return;
    }

    // 캐시 유효성 검사
    if (_isCacheValid(_lastListLoadTime) && state.coupons.isNotEmpty) {
      LoggerUtil.d('🎫 캐시된 쿠폰 목록 사용');
      return;
    }

    try {
      _isLoadingList = true;

      // 안전하게 상태 업데이트 (Future microtask 사용)
      unawaited(Future.microtask(() {
        if (mounted) {
          state = state.copyWith(isLoading: true, errorMessage: '');
          startLoading();
        }
      }));

      final coupons = await _getCouponListUseCase.execute();
      _lastListLoadTime = DateTime.now();

      // 안전하게 상태 업데이트 (Future microtask 사용)
      unawaited(Future.microtask(() {
        if (mounted) {
          state = state.copyWith(
            coupons: coupons,
            isLoading: false,
            lastUpdated: _lastListLoadTime,
            errorMessage: '',
          );
          finishLoading();
        }
      }));

      LoggerUtil.i('🎫 쿠폰 목록 로드 완료: ${coupons.length}개');
    } catch (e) {
      _handleError(e);
      finishLoading();
      LoggerUtil.e('🎫 쿠폰 목록 로드 실패', e);
    } finally {
      _isLoadingList = false;
    }
  }

  // Private helper methods
  Future<bool> _handleSuccess() async {
    _invalidateCache();
    await loadCouponCount(forceRefresh: true);

    // 안전하게 상태 업데이트 (Future microtask 사용)
    unawaited(Future.microtask(() {
      if (mounted) {
        state = state.copyWith(
          isApplying: false,
          modalEvent: CouponModalEvent.success,
        );
      }
    }));

    return true;
  }

  bool _handleAlreadyIssued(AlreadyIssuedFailure failure) {
    // 안전하게 상태 업데이트 (Future microtask 사용)
    unawaited(Future.microtask(() {
      if (mounted) {
        state = state.copyWith(
          isApplying: false,
          errorMessage: failure.message,
          modalEvent: CouponModalEvent.alreadyIssued,
        );
      }
    }));

    return false;
  }

  bool _handleAuthorizationFailure(AuthorizationFailure failure) {
    // 안전하게 상태 업데이트 (Future microtask 사용)
    unawaited(Future.microtask(() {
      if (mounted) {
        state = state.copyWith(
          isApplying: false,
          errorMessage: failure.message,
          modalEvent: CouponModalEvent.needLogin,
        );
      }
    }));

    return false;
  }

  bool _handleTimeLimitFailure(CouponTimeLimitFailure failure) {
    // 안전하게 상태 업데이트 (Future microtask 사용)
    unawaited(Future.microtask(() {
      if (mounted) {
        state = state.copyWith(
          isApplying: false,
          errorMessage: failure.message,
          modalEvent: CouponModalEvent.timeLimit,
        );
        LoggerUtil.w('🎫 쿠폰 발급 실패: 시간 제한 - ${failure.message}');
      }
    }));
    return false;
  }

  bool _handleFailure(CouponApplyFailure failure) {
    // 안전하게 상태 업데이트 (Future microtask 사용)
    unawaited(Future.microtask(() {
      if (mounted) {
        state = state.copyWith(
          isApplying: false,
          errorMessage: failure.message,
          modalEvent: CouponModalEvent.error,
        );
      }
    }));

    return false;
  }

  void _invalidateCache() {
    _lastCountLoadTime = null;
    _lastListLoadTime = null;
  }

  // Public methods for state management
  void setModalEvent(CouponModalEvent event) {
    // 안전하게 상태 업데이트 (Future microtask 사용)
    unawaited(Future.microtask(() {
      if (mounted) {
        state = state.copyWith(modalEvent: event);
      }
    }));
  }

  void clearModalEvent() {
    // 안전하게 상태 업데이트 (Future microtask 사용)
    unawaited(Future.microtask(() {
      if (mounted) {
        // 이벤트 초기화할 때 isApplying도 확실히 false로 설정
        state = state.copyWith(
            modalEvent: CouponModalEvent.none, isApplying: false);
      }
    }));
  }

  void clearError() {
    clearErrorState();
    // 안전하게 상태 업데이트 (Future microtask 사용)
    unawaited(Future.microtask(() {
      if (mounted) {
        state = state.copyWith(errorMessage: '');
      }
    }));
  }

  // 상태 강제 리셋 - 페이지 이동 시 호출되어 일관된 상태 유지
  void resetState() {
    _isLoadingCount = false;
    _isLoadingList = false;
    _isApplyingCoupon = false;

    unawaited(Future.microtask(() {
      if (mounted) {
        state = state.copyWith(
          isLoading: false,
          isApplying: false,
          modalEvent: CouponModalEvent.none,
          errorMessage: '',
        );
      }
    }));
  }
}

/// 쿠폰 ViewModel Provider
final couponViewModelProvider =
    StateNotifierProvider.autoDispose<CouponViewModel, CouponState>((ref) {
  final getCouponCountUseCase = ref.watch(getCouponCountUseCaseProvider);
  final getCouponListUseCase = ref.watch(getCouponListUseCaseProvider);
  final applyCouponUseCase = ref.watch(applyCouponUseCaseProvider);
  return CouponViewModel(
    getCouponCountUseCase: getCouponCountUseCase,
    getCouponListUseCase: getCouponListUseCase,
    applyCouponUseCase: applyCouponUseCase,
    ref: ref,
  );
});
