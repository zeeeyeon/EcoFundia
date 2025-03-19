import 'package:equatable/equatable.dart';

/// 회원가입 엔티티
/// 비즈니스 로직에서 사용할 순수한 도메인 객체
class SignUpEntity extends Equatable {
  final String email;
  final String nickname;
  final String gender;
  final int age;
  final String? token;

  const SignUpEntity({
    required this.email,
    required this.nickname,
    required this.gender,
    required this.age,
    this.token,
  });

  @override
  List<Object?> get props => [email, nickname, gender, age, token];
}
