import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../data/models/profile_model.dart';

class ProfileCard extends StatelessWidget {
  final ProfileModel profile;

  const ProfileCard({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(height: 24, thickness: 1, color: Colors.grey),
        const SizedBox(height: 8),
        // 아이콘 버튼 3개 (펀딩+, 후기, 알림 신청)
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildFeatureButton(
              context,
              icon: Icons.card_giftcard,
              label: "내 펀딩",
              route: '/my-funding', // 내 펀딩 이동
            ),
            _buildFeatureButton(
              context,
              icon: Icons.rate_review,
              label: "내 후기",
              route: '/my-reviews', // 후기 작성 페이지 이동
            ),
            _buildFeatureButton(
              context,
              icon: Icons.edit,
              label: "프로필 수정",
              route: '/profile-edit', // 프로필 수정 페이지로 이동 (추후 구현 예정)
            ),
          ],
        ),

        const SizedBox(height: 8),
        const Divider(height: 24, thickness: 1, color: Colors.grey),
      ],
    );
  }

  /// 개별 기능 버튼 위젯
  Widget _buildFeatureButton(BuildContext context,
      {required IconData icon, required String label, required String route}) {
    return GestureDetector(
      onTap: () {
        context.push(route); // ✅ 해당 페이지로 이동
      },
      child: Column(
        children: [
          Icon(icon, size: 30, color: Colors.black87),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontSize: 14)),
        ],
      ),
    );
  }
}
