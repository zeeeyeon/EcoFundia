import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import 'package:front/shared/payment/domain/usecases/payment_use_case.dart';
import 'package:front/shared/payment/data/repositories/payment_repository_impl.dart';
import 'package:front/shared/payment/domain/repositories/payment_repository.dart';
import 'package:front/shared/payment/ui/state/payment_state.dart';
import 'package:front/shared/payment/data/services/payment_api_service.dart';
import 'package:front/features/home/domain/entities/project_entity.dart';
import 'package:front/shared/payment/domain/entities/payment_entity.dart';

/// 결제 관련 ViewModel
class PaymentViewModel extends StateNotifier<PaymentState> {
  final PaymentUseCase _useCase;
  final Logger _logger = Logger();

  PaymentViewModel(this._useCase) : super(PaymentState.initial());

  /// 결제 정보 로드
  Future<void> loadPaymentInfo(String productId) async {
    try {
      state = PaymentState.loading();

      final payment = await _useCase.loadPaymentInfo(productId);

      state = PaymentState.success(payment);
      _logger.d('결제 정보 로드 성공: ${payment.productName}');
    } catch (e) {
      _logger.e('결제 정보 로드 실패', error: e);
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
  Future<void> applyCoupon(String couponCode) async {
    if (state.payment == null || couponCode.isEmpty) return;

    try {
      state = state.applyingCoupon();

      final discountAmount = await _useCase.applyCoupon(couponCode);

      state = state.couponApplied(discountAmount);
      _logger.d('쿠폰 적용 성공: $couponCode, 할인금액: $discountAmount');
    } catch (e) {
      _logger.e('쿠폰 적용 실패', error: e);
      state = state.copyWith(
        isApplyingCoupon: false,
        error: '쿠폰 적용 중 오류가 발생했습니다: ${e.toString()}',
      );
    }
  }

  /// 쿠폰 적용 (API에서 가져온 쿠폰 사용)
  void applyCouponWithId(int couponId, int discountAmount) {
    if (state.payment == null) return;

    try {
      state = state.applyingCoupon();

      // 현재 상태의 결제 객체에 쿠폰 정보 적용
      final updatedPayment = state.payment!.copyWith(
        appliedCouponId: couponId,
        couponDiscount: discountAmount,
      );

      state = state.copyWith(
        isApplyingCoupon: false,
        payment: updatedPayment,
        error: null,
      );
      _logger.d('쿠폰 적용 성공: ID $couponId, 할인금액: $discountAmount');
    } catch (e) {
      _logger.e('쿠폰 적용 실패', error: e);
      state = state.copyWith(
        isApplyingCoupon: false,
        error: '쿠폰 적용 중 오류가 발생했습니다: ${e.toString()}',
      );
    }
  }

  /// 쿠폰 제거
  void removeCoupon() {
    if (state.payment == null) return;

    // 쿠폰 정보 제거
    final updatedPayment = state.payment!.copyWith(
      appliedCouponId: 0,
      couponDiscount: 0,
    );

    state = state.copyWith(
      payment: updatedPayment,
    );
    _logger.d('쿠폰 제거됨');
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
  Future<bool> processPayment() async {
    if (state.payment == null) return false;

    try {
      state = state.copyWith(isLoading: true);

      final result = await _useCase.processPayment(state.payment!);

      state = state.copyWith(isLoading: false);
      _logger.d('결제 처리 결과: $result');
      return result;
    } catch (e) {
      _logger.e('결제 처리 실패', error: e);
      state = state.copyWith(
        isLoading: false,
        error: '결제 처리 중 오류가 발생했습니다.',
      );
      return false;
    }
  }

  /// 프로젝트 엔티티를 이용해 결제 정보 초기화 (API 호출 대신 전달된 데이터 사용)
  Future<void> initializePaymentFromProject(ProjectEntity project) async {
    try {
      _logger.d('프로젝트 데이터로부터 결제 정보 초기화: ${project.id}');

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
      _logger.e('결제 정보 초기화 실패', error: e);
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
  return PaymentRepositoryImpl(apiService);
});

/// UseCase Provider
final paymentUseCaseProvider = Provider<PaymentUseCase>((ref) {
  final repository = ref.watch(paymentRepositoryProvider);
  return PaymentUseCase(repository);
});

/// ViewModel Provider
final paymentViewModelProvider =
    StateNotifierProvider<PaymentViewModel, PaymentState>((ref) {
  final useCase = ref.watch(paymentUseCaseProvider);
  return PaymentViewModel(useCase);
});
