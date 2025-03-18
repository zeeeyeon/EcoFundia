import '../models/profile_model.dart';

class ProfileService {
  // MokData를 반환하는 함수 (추후 API 연동 예정)
  Future<ProfileModel> fetchUserProfile() async {
    await Future.delayed(const Duration(seconds: 1)); // Mock API 응답 대기 시간

    return ProfileModel(
      username: "홍길동",
      email: "hong@example.com",
      joinDate: "2023-05-10",
      totalDonations: 5,
      totalAmount: 120000,
    );
  }
}
