class ProfileModel {
  final String username;
  final String email;
  final String joinDate;
  final int totalDonations; // 총 후원 횟수
  final int totalAmount; // 총 후원 금액

  ProfileModel({
    required this.username,
    required this.email,
    required this.joinDate,
    required this.totalDonations,
    required this.totalAmount,
  });

  /// JSON 데이터를 Dart 객체로 변환
  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      joinDate: json['joinDate'] ?? '',
      totalDonations: json['totalDonations'] ?? 0,
      totalAmount: json['totalAmount'] ?? 0,
    );
  }
}
