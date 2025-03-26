import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import 'package:front/shared/payment/domain/entities/payment_entity.dart';
import 'package:front/shared/payment/domain/usecases/payment_use_case.dart';
import 'package:front/shared/payment/data/repositories/payment_repository_impl.dart';
import 'package:front/shared/payment/domain/repositories/payment_repository.dart';
import 'package:front/shared/payment/ui/state/payment_state.dart';
import 'package:front/shared/payment/data/services/payment_api_service.dart';

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
