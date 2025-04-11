import 'package:equatable/equatable.dart';
import 'package:front/features/mypage/ui/view_model/coupon_view_model.dart';
import 'package:front/features/mypage/domain/entities/coupon_entity.dart';

/// 쿠폰 상태 클래스
class CouponState extends Equatable {
  /// 쿠폰 개수
  final int couponCount;

  /// 로딩 중 여부
  final bool isLoading;

  /// 쿠폰 발급 중 여부
  final bool isApplying;

  /// 마지막 업데이트 시간
  final DateTime? lastUpdated;

  /// 에러 메시지
  final String errorMessage;

  /// 네트워크 에러 여부
  final bool isNetworkError;

  /// 모달 이벤트
  final CouponModalEvent modalEvent;

  /// 쿠폰 목록
  final List<CouponEntity> coupons;

  /// 발생한 오류 객체 (오류 없을 시 null)
  final dynamic error;

  /// 생성자
  const CouponState({
    this.couponCount = 0,
    this.isLoading = false,
    this.isApplying = false,
    this.lastUpdated,
    this.errorMessage = '',
    this.isNetworkError = false,
    this.modalEvent = CouponModalEvent.none,
    this.coupons = const [],
    this.error,
  });

  /// 초기 상태 생성
  factory CouponState.initial() => const CouponState();

  /// 상태 복사본 생성
  CouponState copyWith({
    int? couponCount,
    bool? isLoading,
    bool? isApplying,
    DateTime? lastUpdated,
    String? errorMessage,
    bool? isNetworkError,
    CouponModalEvent? modalEvent,
    List<CouponEntity>? coupons,
    dynamic error,
    bool clearError = false, // 오류를 명시적으로 null로 설정할지 여부
  }) {
    return CouponState(
      couponCount: couponCount ?? this.couponCount,
      isLoading: isLoading ?? this.isLoading,
      isApplying: isApplying ?? this.isApplying,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      errorMessage: errorMessage ?? this.errorMessage,
      isNetworkError: isNetworkError ?? this.isNetworkError,
      modalEvent: modalEvent ?? this.modalEvent,
      coupons: coupons ?? this.coupons,
      error: clearError ? null : error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [
        couponCount,
        isLoading,
        isApplying,
        lastUpdated,
        errorMessage,
        isNetworkError,
        modalEvent,
        coupons,
        error,
      ];

  @override
  String toString() {
    return 'CouponState('
        'couponCount: $couponCount, '
        'isLoading: $isLoading, '
        'isApplying: $isApplying, '
        'lastUpdated: $lastUpdated, '
        'errorMessage: $errorMessage, '
        'isNetworkError: $isNetworkError, '
        'modalEvent: $modalEvent, '
        'coupons: ${coupons.length} items, '
        'error: $error)';
  }
}
