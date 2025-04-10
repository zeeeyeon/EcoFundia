import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:front/shared/payment/domain/usecases/payment_use_case.dart';
import 'package:front/shared/payment/data/repositories/payment_repository_impl.dart';
import 'package:front/shared/payment/domain/repositories/payment_repository.dart';
import 'package:front/shared/payment/ui/state/payment_state.dart';
import 'package:front/shared/payment/data/services/payment_api_service.dart';
import 'package:front/features/home/domain/entities/project_entity.dart';
import 'package:front/shared/payment/domain/entities/payment_entity.dart';
import 'package:front/utils/logger_util.dart';
import 'package:flutter/material.dart';
import 'package:front/shared/utils/error_handler.dart';

/// 결제 관련 ViewModel
class PaymentViewModel extends StateNotifier<PaymentState> {
  final PaymentUseCase _useCase;

  PaymentViewModel(this._useCase) : super(PaymentState.initial());

  /// 결제 정보 로드
  Future<void> loadPaymentInfo(String productId) async {
    try {
      state = PaymentState.loading();

      final payment = await _useCase.loadPaymentInfo(productId);

      state = PaymentState.success(payment);
      LoggerUtil.d('결제 정보 로드 성공: ${payment.productName}');
    } catch (e) {
      LoggerUtil.e('결제 정보 로드 실패: $e');
      state = PaymentState.error('결제 정보를 불러오는 중 오류가 발생했습니다.');
    }
  }

  /// 수량 증가
  void incrementQuantity() {
    if (state.payment == null) return;

    final currentQuantity = state.payment!.quantity;
    state = state.updateQuantity(currentQuantity + 1);
  }

  /// 수량 감소
  void decrementQuantity() {
    if (state.payment == null) return;

    final currentQuantity = state.payment!.quantity;
    if (currentQuantity > 1) {
      state = state.updateQuantity(currentQuantity - 1);
    }
  }

  /// 쿠폰 적용
  Future<void> applyCoupon(BuildContext context, String couponCode) async {
    if (state.payment == null || couponCode.isEmpty) return;

    try {
      state = state.applyingCoupon();

      final discountAmount = await _useCase.applyCoupon(couponCode);

      state = state.couponApplied(discountAmount);
      LoggerUtil.d('쿠폰 적용 성공: $couponCode, 할인금액: $discountAmount');
    } catch (e) {
      if (context.mounted) {
        ErrorHandler.handleError(
          context,
          e,
          operationDescription: '쿠폰 적용',
        );
      }

      state = state.copyWith(isApplyingCoupon: false);
    }
  }

  /// 쿠폰 적용 (API에서 가져온 쿠폰 사용)
  void applyCouponWithId(
      BuildContext context, int couponId, int discountAmount) {
    if (state.payment == null) return;

    try {
      state = state.applyingCoupon();

      // 현재 상태의 결제 객체에 쿠폰 정보 적용
      final updatedPayment = state.payment!.copyWith(
        appliedCouponId: couponId,
        couponDiscount: discountAmount, // UI 표시용으로 할인 금액은 유지
      );

      state = state.copyWith(
        isApplyingCoupon: false,
        payment: updatedPayment,
        error: null,
        locallySelectedCouponId: couponId,
      );

      LoggerUtil.d(
          '쿠폰 적용 (UI): ID $couponId, 할인금액: $discountAmount, 로컬 상태 업데이트됨');
    } catch (e) {
      if (context.mounted) {
        ErrorHandler.handleError(
          context,
          e,
          operationDescription: '쿠폰 적용 (ID)',
        );
      }

      state = state.copyWith(isApplyingCoupon: false);
    }
  }

  /// 쿠폰 제거
  void removeCoupon() {
    if (state.payment == null) return;

    LoggerUtil.d(
        '쿠폰 제거 시작 - 이전 쿠폰 ID: ${state.payment!.appliedCouponId}, 할인금액: ${state.payment!.couponDiscount}');

    // 쿠폰 정보 제거 (할인 금액도 0으로)
    final updatedPayment = state.payment!.copyWith(
      appliedCouponId: 0,
      couponDiscount: 0,
    );

    state = state.copyWith(
      payment: updatedPayment,
      locallySelectedCouponId: null,
      isApplyingCoupon: false,
    );

    LoggerUtil.d('쿠폰 제거 완료 - 로컬 선택 상태 초기화됨');
  }

  /// 결제 프로세스 시작
  void startPaymentProcess() {
    if (state.payment == null) return;

    state = state.showConfirmDialog();
  }

  /// 결제 다이얼로그 닫기
  void closePaymentDialog() {
    state = state.hideConfirmDialog();
  }

  /// 결제 처리
  Future<void> processPayment() async {
    if (state.payment == null) return;

    try {
      state = state.copyWith(isLoading: true);

      // 실제 결제 처리 로직을 UseCase를 통해 호출
      final result = await _useCase.processPayment(state.payment!);
      LoggerUtil.d('결제 처리 요청 결과: $result');

      if (!result) {
        // 결제 실패 시 에러 상태 설정
        state = state.copyWith(
          isLoading: false,
          error: '결제 처리에 실패했습니다.',
        );
        LoggerUtil.e('결제 처리 실패: 서버에서 실패 응답');
      } else {
        // 결제 성공 처리
        LoggerUtil.i('결제 처리 성공');
        state = state.copyWith(
          isLoading: false,
          error: null,
        );
      }
    } catch (e) {
      LoggerUtil.e('결제 처리 실패: $e');
      state = state.copyWith(
        isLoading: false,
        error: '결제 처리 중 오류가 발생했습니다: ${e.toString()}',
      );
    } finally {
      // 결제 시도 후 로컬 쿠폰 선택 상태 초기화
      state = state.copyWith(
        locallySelectedCouponId: null,
      );

      LoggerUtil.d('결제 시도 후 로컬 쿠폰 선택 상태 초기화됨');
    }
  }

  /// 프로젝트 엔티티를 이용해 결제 정보 초기화 (API 호출 대신 전달된 데이터 사용)
  Future<void> initializePaymentFromProject(ProjectEntity project) async {
    try {
      LoggerUtil.d('프로젝트 데이터로부터 결제 정보 초기화: ${project.id}');

      // 로딩 상태로 변경
      state = state.copyWith(isLoading: true);

      // ProjectEntity로부터 PaymentEntity 생성 (사용자 주소 정보는 빈 값으로 설정)
      final payment = PaymentEntity.fromProjectEntity(
        project,
        recipientName: '', // 빈 값으로 설정
        address: '', // 빈 값으로 설정
        phoneNumber: '', // 빈 값으로 설정
        isDefaultAddress: false,
      );

      // 상태 업데이트
      state = state.copyWith(
        isLoading: false,
        payment: payment,
        error: null,
      );
    } catch (e) {
      LoggerUtil.e('결제 정보 초기화 실패: $e');
      state = state.copyWith(
        isLoading: false,
        error: '결제 정보를 초기화하는데 실패했습니다: $e',
      );
    }
  }
}

/// Repository Provider
final paymentRepositoryProvider = Provider<PaymentRepository>((ref) {
  final apiService = ref.watch(paymentApiServiceProvider);
  return PaymentRepositoryImpl(apiService, ref);
});

/// UseCase Provider
final paymentUseCaseProvider = Provider<PaymentUseCase>((ref) {
  final repository = ref.watch(paymentRepositoryProvider);
  return PaymentUseCase(repository);
});

/// ViewModel Provider
final paymentViewModelProvider =
    StateNotifierProvider<PaymentViewModel, PaymentState>((ref) {
  final PaymentUseCase useCase = ref.read(paymentUseCaseProvider);
  return PaymentViewModel(useCase);
});
