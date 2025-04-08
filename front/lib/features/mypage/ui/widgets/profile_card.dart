import 'package:flutter/material.dart';
import 'package:front/core/themes/app_colors.dart';
import 'package:front/core/themes/app_text_styles.dart';
import 'package:go_router/go_router.dart';
import '../../data/models/profile_model.dart';

class ProfileCard extends StatelessWidget {
  final ProfileModel profile;

  const ProfileCard({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildFeatureButton(
                context,
                icon: Icons.card_giftcard_outlined,
                label: "내 펀딩",
                route: '/my-funding',
              ),
              _buildFeatureButton(
                context,
                icon: Icons.rate_review_outlined,
                label: "내 후기",
                route: '/my-reviews',
              ),
              _buildFeatureButton(
                context,
                icon: Icons.confirmation_number_outlined,
                label: "쿠폰함",
                route: '/coupons',
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildFeatureButton(BuildContext context,
      {required IconData icon, required String label, required String route}) {
    return InkWell(
      onTap: () {
        context.push(route);
      },
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 28, color: AppColors.textDark),
            const SizedBox(height: 6),
            Text(
              label,
              style: AppTextStyles.body2
                  .copyWith(fontSize: 13, color: AppColors.textDark),
            ),
          ],
        ),
      ),
    );
  }
}
