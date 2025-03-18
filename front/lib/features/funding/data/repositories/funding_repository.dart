import '../services/funding_service.dart';
import '../models/funding_model.dart';

class FundingRepository {
  final FundingService _service;

  FundingRepository(this._service);

  Future<List<FundingModel>> getFundingList() async {
    return await _service.fetchFundingList();
  }
}
