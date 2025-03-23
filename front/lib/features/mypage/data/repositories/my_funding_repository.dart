import '../models/my_funding_model.dart';
import '../services/my_funding_service.dart';

class MyFundingRepository {
  final MyFundingService _service;

  MyFundingRepository(this._service);

  Future<List<MyFundingModel>> getMyFundings() async {
    return await _service.fetchMyFundings();
  }
}
