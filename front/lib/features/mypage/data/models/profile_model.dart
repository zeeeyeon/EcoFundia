class ProfileModel {
  final int userId;
  final String email;
  final String name;
  final String nickname;
  final String gender;
  final String account;
  final int age;
  final DateTime createdAt;

  ProfileModel({
    required this.userId,
    required this.email,
    required this.name,
    required this.nickname,
    required this.gender,
    required this.account,
    required this.age,
    required this.createdAt,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    final user = json['content']['user']; // ✅ 중첩 구조 대응!

    return ProfileModel(
      userId: user['userId'],
      email: user['email'],
      name: user['name'],
      nickname: user['nickname'],
      gender: user['gender'],
      account: user['account'] ?? '',
      age: user['age'],
      createdAt: DateTime.parse(user['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'email': email,
      'name': name,
      'nickname': nickname,
      'gender': gender,
      'account': account,
      'age': age,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  ProfileModel copyWith({
    String? nickname,
    String? account,
  }) {
    return ProfileModel(
      userId: userId,
      email: email,
      name: name,
      nickname: nickname ?? this.nickname,
      gender: gender,
      account: account ?? this.account,
      age: age,
      createdAt: createdAt,
    );
  }
}
