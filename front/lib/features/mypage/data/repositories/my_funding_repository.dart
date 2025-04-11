import '../models/my_funding_model.dart';
import '../services/my_funding_service.dart';
import 'package:dio/dio.dart';

class MyFundingRepository {
  final MyFundingService _service;

  MyFundingRepository(this._service);

  Future<List<MyFundingModel>> getMyFundings({
    int page = 0,
    int size = 10,
    CancelToken? cancelToken,
  }) async {
    return await _service.fetchMyFundings(
      page: page,
      size: size,
      cancelToken: cancelToken,
    );
  }
}
