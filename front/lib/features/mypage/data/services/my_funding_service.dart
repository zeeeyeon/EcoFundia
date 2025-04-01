import 'package:front/core/services/api_service.dart';
import '../models/my_funding_model.dart';

class MyFundingService {
  final ApiService _apiService;

  MyFundingService(this._apiService);

  Future<List<MyFundingModel>> fetchMyFundings(
      {int page = 0, int size = 10}) async {
    final response = await _apiService.get(
      '/user/funding',
      queryParameters: {
        'page': page,
        'size': size,
      },
    );

    final dataList = response.data['content']['content'] as List;
    return dataList.map((json) => MyFundingModel.fromJson(json)).toList();
  }
}
