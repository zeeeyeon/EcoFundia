import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:front/features/mypage/data/repositories/coupon_repository_impl.dart';
import 'package:front/features/mypage/domain/entities/coupon_entity.dart';
import 'package:front/features/mypage/domain/entities/coupon_apply_result.dart';
import 'package:front/features/mypage/domain/use_cases/apply_coupon_use_case.dart';
import 'package:front/features/mypage/domain/use_cases/get_coupon_count_use_case.dart';
import 'package:front/features/mypage/domain/use_cases/get_coupon_list_use_case.dart';
import 'package:front/utils/logger_util.dart';

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

// 쿠폰 ViewModel Provider
final couponViewModelProvider =
    StateNotifierProvider<CouponViewModel, CouponState>((ref) {
  return CouponViewModel(
    getCouponCountUseCase: ref.watch(getCouponCountUseCaseProvider),
    getCouponListUseCase: ref.watch(getCouponListUseCaseProvider),
    applyCouponUseCase: ref.watch(applyCouponUseCaseProvider),
  );
});

/// 쿠폰 모달 이벤트 타입 - UI에서 표시할 모달 종류를 나타냄
enum CouponModalEvent {
  /// 이벤트 없음
  none,

  /// 쿠폰 발급 성공
  success,

  /// 이미 발급된 쿠폰
  alreadyIssued,

  /// 권한 없음 (로그인 필요)
  needLogin,

  /// 일반 에러
  error,
}

// 쿠폰 상태 클래스
class CouponState {
  final bool isLoading;
  final bool isApplying;
  final String errorMessage;
  final int couponCount;
  final List<CouponEntity> coupons;
  final DateTime lastUpdated; // 마지막 업데이트 시간
  final CouponModalEvent modalEvent; // 모달 표시 이벤트

  const CouponState({
    this.isLoading = false,
    this.isApplying = false,
    this.errorMessage = '',
    this.couponCount = 0,
    this.coupons = const [],
    this.lastUpdated = const LocalDateTimeDefault(),
    this.modalEvent = CouponModalEvent.none, // 기본값: 이벤트 없음
  });

  // 복사 생성자
  CouponState copyWith({
    bool? isLoading,
    bool? isApplying,
    String? errorMessage,
    int? couponCount,
    List<CouponEntity>? coupons,
    DateTime? lastUpdated,
    CouponModalEvent? modalEvent,
  }) {
    return CouponState(
      isLoading: isLoading ?? this.isLoading,
      isApplying: isApplying ?? this.isApplying,
      errorMessage: errorMessage ?? this.errorMessage,
      couponCount: couponCount ?? this.couponCount,
      coupons: coupons ?? this.coupons,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      modalEvent: modalEvent ?? this.modalEvent,
    );
  }
}

// 기본 DateTime 값을 위한 클래스
class LocalDateTimeDefault implements DateTime {
  const LocalDateTimeDefault();

  // 기본 millisecondsSinceEpoch 값 구현 (0 반환)
  @override
  int get millisecondsSinceEpoch => 0;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

// 쿠폰 ViewModel
class CouponViewModel extends StateNotifier<CouponState> {
  final GetCouponCountUseCase _getCouponCountUseCase;
  final GetCouponListUseCase _getCouponListUseCase;
  final ApplyCouponUseCase _applyCouponUseCase;

  // 마지막 로드 시간 캐싱을 위한 변수
  DateTime? _lastCountLoadTime;
  DateTime? _lastListLoadTime;

  // 캐시 유효시간 (초)
  static const int _cacheValidSeconds = 30;

  CouponViewModel({
    required GetCouponCountUseCase getCouponCountUseCase,
    required GetCouponListUseCase getCouponListUseCase,
    required ApplyCouponUseCase applyCouponUseCase,
  })  : _getCouponCountUseCase = getCouponCountUseCase,
        _getCouponListUseCase = getCouponListUseCase,
        _applyCouponUseCase = applyCouponUseCase,
        super(const CouponState());

  // 캐시가 유효한지 확인하는 메서드
  bool _isCacheValid(DateTime? lastLoadTime) {
    if (lastLoadTime == null) return false;

    final now = DateTime.now();
    final difference = now.difference(lastLoadTime).inSeconds;
    LoggerUtil.d(
        '🎫 쿠폰 캐시 확인: 마지막 로드로부터 $difference초 경과 (유효시간: $_cacheValidSeconds초)');
    return difference < _cacheValidSeconds;
  }

  // 쿠폰 개수 로드
  Future<void> loadCouponCount({bool forceRefresh = false}) async {
    try {
      // 이미 로딩 중이면 중복 호출 방지
      if (state.isLoading) {
        LoggerUtil.d('🎫 쿠폰 개수 로드 스킵: 이미 로딩 중');
        return;
      }

      // 강제 새로고침이 아니고, 캐시가 유효하면 다시 로드하지 않음
      if (!forceRefresh &&
          _isCacheValid(_lastCountLoadTime) &&
          state.couponCount > 0) {
        LoggerUtil.d(
            '🎫 쿠폰 개수 캐시 사용 (마지막 로드: ${_formatTime(_lastCountLoadTime)})');
        return;
      }

      // 강제 새로고침 로그
      if (forceRefresh) {
        LoggerUtil.d('🎫 쿠폰 개수 강제 새로고침 요청됨');
      }

      // 마지막 요청 시간 기록 (빠르게 기록하여 중복 요청 방지)
      _lastCountLoadTime = DateTime.now();
      LoggerUtil.d('🎫 쿠폰 개수 로드 시작');

      state = state.copyWith(isLoading: true, errorMessage: '');
      final count = await _getCouponCountUseCase.execute();

      // 이전과 같은 개수면 상태 업데이트만 하고 로그 남기지 않음
      if (count == state.couponCount) {
        state =
            state.copyWith(isLoading: false, lastUpdated: _lastCountLoadTime);
        LoggerUtil.d('🎫 쿠폰 개수 변동 없음: $count장');
      } else {
        state = state.copyWith(
            couponCount: count,
            isLoading: false,
            lastUpdated: _lastCountLoadTime);
        LoggerUtil.i('🎫 쿠폰 개수 로드 완료: $count장 (변경됨)');
      }
    } catch (e) {
      LoggerUtil.e('❌ 쿠폰 개수 로드 실패', e);
      state = state.copyWith(
        isLoading: false,
        errorMessage: '쿠폰 개수를 불러오는데 실패했습니다.',
      );
    }
  }

  // 쿠폰 목록 로드
  Future<void> loadCouponList() async {
    try {
      // 이미 로딩 중이면 중복 호출 방지
      if (state.isLoading) return;

      // 캐시가 유효하면 다시 로드하지 않음 (쿠폰이 있는 경우만)
      if (_isCacheValid(_lastListLoadTime) && state.coupons.isNotEmpty) {
        LoggerUtil.d(
            '🎫 쿠폰 목록 캐시 사용 (마지막 로드: ${_formatTime(_lastListLoadTime)})');
        return;
      }

      state = state.copyWith(isLoading: true, errorMessage: '');
      final coupons = await _getCouponListUseCase.execute();
      _lastListLoadTime = DateTime.now();

      state = state.copyWith(
          coupons: coupons, isLoading: false, lastUpdated: _lastListLoadTime);
      LoggerUtil.i('🎫 쿠폰 목록 로드 완료: ${coupons.length}개');
    } catch (e) {
      LoggerUtil.e('❌ 쿠폰 목록 로드 실패', e);
      state = state.copyWith(
        isLoading: false,
        errorMessage: '쿠폰 목록을 불러오는데 실패했습니다.',
      );
    }
  }

  /// 쿠폰 신청
  /// 반환 값: 쿠폰 신청 성공 여부 (UI 레이어 처리용)
  ///
  /// 내부적으로 상태를 업데이트하고 적절한 모달 이벤트를 설정합니다:
  /// - 성공 시: `modalEvent = CouponModalEvent.success`
  /// - 이미 발급된 쿠폰: `modalEvent = CouponModalEvent.alreadyIssued`
  /// - 권한 없음: `modalEvent = CouponModalEvent.needLogin`
  /// - 기타 오류: `modalEvent = CouponModalEvent.error`
  Future<bool> applyCoupon() async {
    LoggerUtil.d('🎫 CouponViewModel: applyCoupon 메서드 시작');

    // 이미 처리 중이면 중복 호출 방지
    if (state.isApplying) {
      LoggerUtil.d('🎫 CouponViewModel: 이미 처리 중입니다 (중복 호출 방지)');
      return false;
    }

    // 처리 시작 상태로 업데이트
    state = state.copyWith(
        isApplying: true, errorMessage: '', modalEvent: CouponModalEvent.none);
    LoggerUtil.d('🎫 CouponViewModel: 상태 업데이트 - 처리 중 (isApplying: true)');

    try {
      LoggerUtil.d('🎫 CouponViewModel: UseCase 호출 시작');
      LoggerUtil.i('🎫 쿠폰 발급 API를 호출합니다 - applyCoupon 시작');

      // UseCase 호출 및 결과 처리
      final result = await _applyCouponUseCase.execute();
      LoggerUtil.d('🎫 CouponViewModel: UseCase 결과 수신: $result');
      LoggerUtil.i('🎫 쿠폰 발급 API 결과: $result');

      // 결과 로그 및 타입 체크
      if (result is AlreadyIssuedFailure) {
        LoggerUtil.d('🎫 CouponViewModel: 결과 타입 - AlreadyIssuedFailure');
      } else if (result is CouponApplySuccess) {
        LoggerUtil.d('🎫 CouponViewModel: 결과 타입 - CouponApplySuccess');
      } else {
        LoggerUtil.d('🎫 CouponViewModel: 결과 타입 - ${result.runtimeType}');
      }

      // CouponApplyResult 타입에 따른 분기 처리
      var processResult = switch (result) {
        // 성공 케이스
        CouponApplySuccess() => await _handleSuccess(),

        // 이미 발급된 쿠폰 케이스
        AlreadyIssuedFailure() => _handleAlreadyIssued(result),

        // 권한 없음 케이스 (로그인 필요)
        AuthorizationFailure() => _handleAuthorizationFailure(result),

        // 기타 실패 케이스
        CouponApplyFailure() => _handleFailure(result),
      };

      // 최종 상태 로그
      LoggerUtil.d(
          '🎫 CouponViewModel: applyCoupon 메서드 종료 - isApplying: ${state.isApplying}, '
          'modalEvent: ${state.modalEvent}, 결과: $processResult');

      return processResult;
    } catch (e) {
      // 예외 처리
      LoggerUtil.e('🎫 CouponViewModel: 예외 발생', e);

      // 상태 업데이트 (isApplying = false)
      state = state.copyWith(
          isApplying: false,
          errorMessage: '쿠폰 신청에 실패했습니다: ${e.toString()}',
          modalEvent: CouponModalEvent.error);

      LoggerUtil.d('🎫 CouponViewModel: 에러 케이스에서 isApplying = false로 설정');
      LoggerUtil.d(
          '🎫 CouponViewModel: applyCoupon 메서드 종료 (예외) - isApplying: ${state.isApplying}, '
          'modalEvent: ${state.modalEvent}, 결과: false');
      return false;
    }
  }

  /// 성공 시 처리
  Future<bool> _handleSuccess() async {
    LoggerUtil.i('🎫 CouponViewModel: 쿠폰 발급 성공 처리');

    // 먼저 상태 업데이트하여 모달이 먼저 표시되도록 함
    state =
        state.copyWith(isApplying: false, modalEvent: CouponModalEvent.success);
    LoggerUtil.d('🎫 CouponViewModel: 성공 케이스에서 isApplying = false로 설정');
    LoggerUtil.d('🎫 CouponViewModel: 성공 모달 이벤트 설정 - ${state.modalEvent}');

    // 쿠폰 개수 갱신 (백그라운드에서 처리)
    _lastCountLoadTime = null; // 캐시 무효화
    await loadCouponCount();

    return true;
  }

  /// 이미 발급된 쿠폰 케이스 처리
  bool _handleAlreadyIssued(AlreadyIssuedFailure failure) {
    LoggerUtil.w('🎫 CouponViewModel: 이미 발급된 쿠폰 처리');

    // 상태 업데이트
    state = state.copyWith(
        isApplying: false,
        errorMessage: failure.message,
        modalEvent: CouponModalEvent.alreadyIssued);
    LoggerUtil.d('🎫 CouponViewModel: 이미 발급된 쿠폰 케이스에서 isApplying = false로 설정');
    LoggerUtil.d('🎫 CouponViewModel: 이미 발급됨 모달 이벤트 설정 - ${state.modalEvent}');
    LoggerUtil.d(
        '🎫 CouponViewModel: 현재 상태 - isApplying: ${state.isApplying}, modalEvent: ${state.modalEvent}');

    return false;
  }

  /// 인증 실패 케이스 처리 (로그인 필요)
  bool _handleAuthorizationFailure(AuthorizationFailure failure) {
    LoggerUtil.w('🎫 CouponViewModel: 권한 없음 - 로그인 필요');

    // 상태 업데이트
    state = state.copyWith(
        isApplying: false,
        errorMessage: failure.message,
        modalEvent: CouponModalEvent.needLogin);
    LoggerUtil.d('🎫 CouponViewModel: 인증 실패 케이스에서 isApplying = false로 설정');
    LoggerUtil.d('🎫 CouponViewModel: 로그인 필요 모달 이벤트 설정 - ${state.modalEvent}');

    return false;
  }

  /// 기타 실패 처리
  bool _handleFailure(CouponApplyFailure failure) {
    LoggerUtil.e('🎫 CouponViewModel: 쿠폰 발급 실패 처리', failure.message);

    // 상태 업데이트
    state = state.copyWith(
        isApplying: false,
        errorMessage: failure.message,
        modalEvent: CouponModalEvent.error);
    LoggerUtil.d('🎫 CouponViewModel: 기타 실패 케이스에서 isApplying = false로 설정');
    LoggerUtil.d('🎫 CouponViewModel: 에러 모달 이벤트 설정 - ${state.modalEvent}');

    return false;
  }

  /// 모달 이벤트 초기화 (모달 표시 후 호출)
  void clearModalEvent() {
    if (state.modalEvent != CouponModalEvent.none) {
      LoggerUtil.d(
          '🎫 CouponViewModel: 모달 이벤트 초기화 (${state.modalEvent} -> none)');
      state = state.copyWith(modalEvent: CouponModalEvent.none);
    }
  }

  // 에러 메시지 초기화
  void clearError() {
    if (state.errorMessage.isNotEmpty) {
      state = state.copyWith(errorMessage: '');
    }
  }

  // 시간 포맷팅 헬퍼 메서드
  String _formatTime(DateTime? dateTime) {
    if (dateTime == null) return 'N/A';
    return '${dateTime.hour}:${dateTime.minute}:${dateTime.second}';
  }
}
