class ProfileModel {
  final int userId;
  final String email;
  final String name;
  final String nickname;
  final String gender;
  final int age;
  final String createdAt;

  ProfileModel({
    required this.userId,
    required this.email,
    required this.name,
    required this.nickname,
    required this.gender,
    required this.age,
    required this.createdAt,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    final user = json['content']['user'];
    return ProfileModel(
      userId: user['userId'],
      email: user['email'],
      name: user['name'],
      nickname: user['nickname'],
      gender: user['gender'],
      age: user['age'],
      createdAt: user['createdAt'],
    );
  }
}
