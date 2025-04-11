import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:front/core/ui/widgets/custom_app_bar.dart';
import 'package:front/utils/funding_status.dart';
import 'package:front/core/themes/app_colors.dart';
import '../view_model/my_funding_view_model.dart';
import '../widgets/my_funding_card.dart';
import '../widgets/my_funding_tab_bar.dart';

class MyFundingScreen extends ConsumerStatefulWidget {
  const MyFundingScreen({super.key});

  @override
  ConsumerState<MyFundingScreen> createState() => _MyFundingScreenState();
}

class _MyFundingScreenState extends ConsumerState<MyFundingScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() {}); // 탭 전환 시 리빌드
    });
    // 화면 진입 시 데이터 새로고침
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.invalidate(myFundingViewModelProvider);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final myFundingsState = ref.watch(myFundingViewModelProvider);

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: const CustomAppBar(
        title: 'My Funding',
        showBackButton: true,
      ),
      body: Column(
        children: [
          MyFundingTabBar(tabController: _tabController),
          Expanded(
            child: myFundingsState.when(
              data: (fundings) {
                final isOngoingTab = _tabController.index == 0;

                final filteredFundings = fundings.where((f) {
                  return isOngoingTab
                      ? isOngoing(f.status)
                      : isSuccess(f.status);
                }).toList();

                // 필터링된 목록이 비어 있는지 확인
                if (filteredFundings.isEmpty) {
                  return const Center(
                    child: Text(
                      '펀딩 목록이 없습니다.',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  );
                } else {
                  // 목록이 있으면 ListView 표시
                  return ListView.builder(
                    itemCount: filteredFundings.length,
                    itemBuilder: (context, index) {
                      return MyFundingCard(funding: filteredFundings[index]);
                    },
                  );
                }
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(child: Text('에러 발생: $err')),
            ),
          ),
        ],
      ),
    );
  }
}
