import 'package:front/features/auth/domain/entities/sign_up_entity.dart';

/// 회원가입 데이터 모델
/// 외부 API와의 통신을 위한 데이터 구조
class SignUpModel {
  final String email;
  final String nickname;
  final String gender;
  final int age;
  final String? token;

  const SignUpModel({
    required this.email,
    required this.nickname,
    required this.gender,
    required this.age,
    this.token,
  });

  /// JSON 변환
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'email': email,
      'nickname': nickname,
      'gender': gender,
      'age': age,
    };

    if (token != null) {
      data['token'] = token;
    }

    return data;
  }

  /// JSON으로부터 객체 생성
  factory SignUpModel.fromJson(Map<String, dynamic> json) {
    return SignUpModel(
      email: json['email'] as String,
      nickname: json['nickname'] as String,
      gender: json['gender'] as String,
      age: json['age'] as int,
      token: json['token'] as String?,
    );
  }

  /// 도메인 엔티티로 변환
  SignUpEntity toEntity() {
    return SignUpEntity(
      email: email,
      nickname: nickname,
      gender: gender,
      age: age,
      token: token,
    );
  }

  /// 도메인 엔티티로부터 모델 생성
  factory SignUpModel.fromEntity(SignUpEntity entity) {
    return SignUpModel(
      email: entity.email,
      nickname: entity.nickname,
      gender: entity.gender,
      age: entity.age,
      token: entity.token,
    );
  }
}
