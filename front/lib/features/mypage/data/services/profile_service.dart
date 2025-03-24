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
          "account": "농협 302-1234-5678-91",
          "createdAt": "2025-03-19T12:34:56Z"
        }
      }
    };

    final userJson = mockJson['content']?['user'] as Map<String, dynamic>;
    return ProfileModel.fromJson(userJson);
  }

  // 계좌 정보까지 포함한 업데이트 함수 (추후 API 연동 시 사용)
  Future<void> updateProfile(
      {required String nickname, required String account}) async {
    // TODO: 실제 API 연동 예정
    print('[MOK] 업데이트 요청 - 닉네임: $nickname, 계좌: $account');
    await Future.delayed(const Duration(milliseconds: 500)); // Mok 응답 시간
  }
}
