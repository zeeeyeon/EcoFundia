// 마이페이지 화면에 펀딩들의 총 펀딩 금액
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:front/features/mypage/data/repositories/total_funding_repository.dart';
import 'package:front/features/mypage/data/services/total_funding_service.dart';
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
  final repository = ref.read(totalFundingRepositoryProvider);
  return await repository.getTotalFundingAmount();
});
