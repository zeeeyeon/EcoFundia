import 'package:equatable/equatable.dart';

/// 사용자 정보를 나타내는 엔티티 클래스
/// 비즈니스 로직에서 사용되는 순수한 도메인 객체
class UserEntity extends Equatable {
  final int userId;
  final String email;
  final String name;
  final String nickname;
  final String gender;
  final int age;
  final DateTime createdAt;

  const UserEntity({
    required this.userId,
    required this.email,
    required this.name,
    required this.nickname,
    required this.gender,
    required this.age,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        userId,
        email,
        name,
        nickname,
        gender,
        age,
        createdAt,
      ];
}
