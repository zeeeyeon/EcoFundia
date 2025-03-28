import 'package:equatable/equatable.dart';

/// 회원가입 데이터 엔티티
class SignUpEntity extends Equatable {
  final String nickname;
  final String gender;
  final int age;
  final String? token;

  const SignUpEntity({
    required this.nickname,
    required this.gender,
    required this.age,
    this.token,
  });

  @override
  List<Object?> get props => [nickname, gender, age, token];
}
