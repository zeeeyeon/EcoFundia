import 'package:front/features/mypage/domain/entities/coupon_apply_result.dart';
import 'package:front/features/mypage/domain/repositories/coupon_repository.dart';
import 'package:front/utils/logger_util.dart';

/// 쿠폰 발급 신청 UseCase
class ApplyCouponUseCase {
  final CouponRepository _repository;

  const ApplyCouponUseCase(this._repository);

  /// UseCase 실행: 쿠폰 발급 신청
  ///
  /// 반환 타입: [CouponApplyResult]
  /// - [CouponApplySuccess] - 쿠폰 발급 성공
  /// - [AlreadyIssuedFailure] - 이미 발급된 쿠폰
  /// - [NetworkFailure] - 네트워크 오류
  /// - [UnknownFailure] - 알 수 없는 오류
  Future<CouponApplyResult> execute() async {
    LoggerUtil.d('🎫 ApplyCouponUseCase: execute 시작');
    LoggerUtil.i('🎫 쿠폰 발급 API 호출을 리포지토리에 요청합니다.');

    try {
      LoggerUtil.i('🎫 [API 호출 시작] 리포지토리의 applyCoupon() 호출');
      final result = await _repository.applyCoupon();
      LoggerUtil.i('🎫 [API 호출 완료] 리포지토리에서 결과 수신: $result');
      LoggerUtil.d('🎫 ApplyCouponUseCase: execute 완료');
      return result;
    } catch (e) {
      // Repository가 CouponApplyResult를 반환하므로, 여기서 예외 처리는 필요 없지만,
      // 만약 다른 UseCase에서 추가적인 로직 발생 시 예외가 발생할 수 있으므로 처리
      LoggerUtil.e('🎫 ApplyCouponUseCase: 에러 발생', e);
      return UnknownFailure(e.toString());
    }
  }
}
