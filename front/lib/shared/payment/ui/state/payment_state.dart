import 'package:equatable/equatable.dart';
import 'package:front/shared/payment/domain/entities/payment_entity.dart';

/// 결제 화면의 상태를 관리하는 클래스
class PaymentState extends Equatable {
  final PaymentEntity? payment;
  final bool isLoading;
  final String? error;
  final bool isApplyingCoupon;
  final bool showSuccessDialog;

  /// 로컬에서 선택한 쿠폰 ID (UI 업데이트용)
  final int? locallySelectedCouponId;

  const PaymentState({
    this.payment,
    this.isLoading = false,
    this.error,
    this.isApplyingCoupon = false,
    this.showSuccessDialog = false,
    this.locallySelectedCouponId,
  });

  // 초기 상태
  factory PaymentState.initial() => const PaymentState();

  // 로딩 상태
  factory PaymentState.loading() => const PaymentState(isLoading: true);

  // 에러 상태
  factory PaymentState.error(String message) => PaymentState(error: message);

  // 성공 상태
  factory PaymentState.success(PaymentEntity payment) =>
      PaymentState(payment: payment);

  // 쿠폰 적용 중
  PaymentState applyingCoupon() => copyWith(isApplyingCoupon: true);

  // 쿠폰 적용 완료
  PaymentState couponApplied(int discountAmount) {
    if (payment == null) return this;

    return copyWith(
      isApplyingCoupon: false,
      payment: payment!.copyWith(couponDiscount: discountAmount),
    );
  }

  // 수량 변경
  PaymentState updateQuantity(int newQuantity) {
    if (payment == null || newQuantity < 1) return this;

    return copyWith(
      payment: payment!.copyWith(quantity: newQuantity),
    );
  }

  // 성공 다이얼로그 표시
  PaymentState showConfirmDialog() => copyWith(showSuccessDialog: true);

  // 성공 다이얼로그 숨김
  PaymentState hideConfirmDialog() => copyWith(showSuccessDialog: false);

  // 상태 복사 메소드
  PaymentState copyWith({
    PaymentEntity? payment,
    bool? isLoading,
    String? error,
    bool? isApplyingCoupon,
    bool? showSuccessDialog,
    int? locallySelectedCouponId,
  }) {
    return PaymentState(
      payment: payment ?? this.payment,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      isApplyingCoupon: isApplyingCoupon ?? this.isApplyingCoupon,
      showSuccessDialog: showSuccessDialog ?? this.showSuccessDialog,
      locallySelectedCouponId:
          locallySelectedCouponId ?? this.locallySelectedCouponId,
    );
  }

  @override
  List<Object?> get props => [
        payment,
        isLoading,
        error,
        isApplyingCoupon,
        showSuccessDialog,
        locallySelectedCouponId,
      ];
}
