import '../models/profile_model.dart';
import '../services/profile_service.dart';

class ProfileRepository {
  final ProfileService service;

  ProfileRepository(this.service);

  // ✅ 프로필 데이터 가져오기
  Future<ProfileModel> getProfile() async {
    return await service.fetchUserProfile();
  }
}
