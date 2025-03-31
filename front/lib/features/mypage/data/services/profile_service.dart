import 'package:front/core/services/api_service.dart';
import '../models/profile_model.dart';

class ProfileService {
  final ApiService _apiService;

  ProfileService(this._apiService);

  // 사용자 프로필 조회
  Future<ProfileModel> fetchUserProfile() async {
    final response = await _apiService.get('/user/me');
    return ProfileModel.fromJson(
        response.data); // response.data 안에 content.user 있음
  }

  // 프로필 업데이트
  Future<void> updateProfile({
    required String nickname,
    required String account,
  }) async {
    final body = {
      'nickname': nickname,
      'account': account,
    };

    await _apiService.put('/user/me', data: body);
  }
}
