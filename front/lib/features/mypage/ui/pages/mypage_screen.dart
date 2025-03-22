import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:front/features/mypage/ui/widgets/funding_status_card.dart';
import 'package:front/features/mypage/ui/widgets/mypage_support_section.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/ui/widgets/custom_app_bar.dart';
import '../view_model/profile_view_model.dart';
import '../widgets/profile_card.dart';
import '../widgets/greeting_message.dart';

class MypageScreen extends ConsumerWidget {
  const MypageScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileState = ref.watch(profileProvider);

    return Scaffold(
      appBar: CustomAppBar(
        title: "My Page",
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications), // 🔔 알림 아이콘
            onPressed: () {
              context.push('/notifications'); // 알림 페이지로 이동
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings), // ⚙ 설정 아이콘
            onPressed: () {
              context.push('/settings'); // 설정 페이지로 이동
            },
          ),
        ],
      ),
      body: profileState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text("오류 발생: $err")),
        data: (profile) => SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GreetingMessage(profile: profile),
              const SizedBox(height: 8),
              ProfileCard(profile: profile),
              const FundingStatusCard(
                totalFundingAmount: 53500,
                couponCount: 5,
              ),
              const CustomerSupportSection(),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
