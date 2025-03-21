import '../models/profile_model.dart';

class ProfileService {
  // MokData를 반환하는 함수 (추후 API 연동 예정)
  Future<ProfileModel> fetchUserProfile() async {
    await Future.delayed(const Duration(seconds: 1)); // Mock API 응답 대기 시간

    // Mok JSON 형식과 동일하게 가공
    final mockJson = {
      "status": {"code": "SU", "message": "Success"},
      "content": {
        "user": {
          "userId": 1,
          "email": "user@example.com",
          "name": "홍길동",
          "nickname": "길동이",
          "gender": "MALE",
          "age": 30,
          "createdAt": "2025-03-19T12:34:56Z"
        }
      }
    };

    return ProfileModel.fromJson(mockJson);
  }
}
