// 마이페이지 화면에 펀딩들의 총 펀딩 금액
import 'package:front/core/services/api_service.dart';

class TotalFundingService {
  final ApiService _apiService;

  TotalFundingService(this._apiService);

  Future<int> fetchTotalFundingAmount() async {
    final response = await _apiService.get('/user/funding/total');
    final data = response.data;
    return data['content']['total'] as int;
  }
}
