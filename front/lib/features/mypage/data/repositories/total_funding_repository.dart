// 마이페이지 화면에 펀딩들의 총 펀딩 금액
import '../services/total_funding_service.dart';

class TotalFundingRepository {
  final TotalFundingService service;

  TotalFundingRepository(this.service);

  Future<int> getTotalFundingAmount() async {
    return await service.fetchTotalFundingAmount();
  }
}
