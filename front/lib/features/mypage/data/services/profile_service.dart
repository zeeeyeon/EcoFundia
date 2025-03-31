import 'package:front/core/services/api_service.dart';
import '../models/profile_model.dart';

class ProfileService {
  final ApiService _apiService;

  ProfileService(this._apiService);

  // ✅ [실제 API 연동] 사용자 프로필 조회
  Future<ProfileModel> fetchUserProfile() async {
    final response = await _apiService.get('/user/me');
    return ProfileModel.fromJson(
        response.data); // response.data 안에 content.user 있음
  }

  // ❗ [MokData 유지] 프로필 업데이트 (추후 실제 API 연동 예정)
  Future<void> updateProfile({
    required String nickname,
    required String account,
  }) async {
    print('[MOK] 업데이트 요청 - 닉네임: $nickname, 계좌: $account');
    await Future.delayed(const Duration(milliseconds: 500));
  }
}
