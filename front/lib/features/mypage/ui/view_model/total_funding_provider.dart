// 마이페이지 화면에 펀딩들의 총 펀딩 금액
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:front/features/mypage/data/repositories/total_funding_repository.dart';
import 'package:front/features/mypage/data/services/total_funding_service.dart';
import 'package:front/core/services/storage_service.dart';
import 'package:front/utils/logger_util.dart';
import '../../../../core/services/api_service.dart';

// 서비스 & 레포지토리 주입
final totalFundingServiceProvider = Provider(
  (ref) => TotalFundingService(ref.read(apiServiceProvider)),
);

final totalFundingRepositoryProvider = Provider(
  (ref) => TotalFundingRepository(ref.read(totalFundingServiceProvider)),
);

// 실제 FutureProvider (화면에서 watch)
final totalFundingAmountProvider = FutureProvider<int>((ref) async {
  try {
    // 인증 상태 확인
    final isAuthenticated = await StorageService.isAuthenticated();

    // 인증되지 않은 경우 API 호출 중단
    if (!isAuthenticated) {
      LoggerUtil.w('⚠️ 총 펀딩 금액 로드 취소: 인증되지 않음');
      return 0; // 로그인하지 않은 경우 0원 반환
    }

    final repository = ref.read(totalFundingRepositoryProvider);
    return await repository.getTotalFundingAmount();
  } catch (e) {
    LoggerUtil.e('❌ 총 펀딩 금액 로드 실패', e);
    return 0; // 오류 발생 시 0원 반환
  }
});
