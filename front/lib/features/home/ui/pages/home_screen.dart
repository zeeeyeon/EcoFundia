import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';
import 'package:front/core/constants/app_strings.dart';
import 'package:front/core/themes/app_text_styles.dart';
import 'package:front/core/themes/app_colors.dart';
import 'package:front/features/home/ui/view_model/home_provider.dart';
import 'package:front/features/home/ui/widgets/project_carousel.dart';
import 'package:front/features/home/ui/widgets/total_fund_card.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  Timer? _timer;
  String _currentTime = '';

  @override
  void initState() {
    super.initState();
    _updateTime();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer =
        Timer.periodic(const Duration(seconds: 1), (timer) => _updateTime());
  }

  void _updateTime() {
    if (!mounted) return;
    final now = DateTime.now();
    setState(() {
      _currentTime =
          '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}';
    });
  }

  @override
  Widget build(BuildContext context) {
    final topProjects = ref.watch(topProjectsProvider);
    final totalFund = ref.watch(totalFundProvider);
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 360; // 작은 화면 기준

    // 화면 크기에 따른 동적 패딩 및 간격 계산
    final mainPadding = isSmallScreen ? 12.0 : 16.0;
    final titleSpacing = isSmallScreen ? 12.0 : 16.0;
    final sectionSpacing = isSmallScreen ? 16.0 : 24.0;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.all(mainPadding),
                child: Column(
                  children: [
                    Text(
                      AppStrings.appName,
                      style: AppTextStyles.mainTitle.copyWith(
                        color: AppColors.primary,
                        fontSize:
                            isSmallScreen ? 24.0 : null, // 작은 화면에서는 폰트 크기 줄임
                      ),
                    ),
                    SizedBox(height: titleSpacing),
                    Text(
                      _currentTime,
                      style: AppTextStyles.timeStyle.copyWith(
                        fontSize:
                            isSmallScreen ? 14.0 : null, // 작은 화면에서는 폰트 크기 줄임
                      ),
                    ),
                    SizedBox(height: sectionSpacing),
                    Text(
                      AppStrings.totalFund,
                      style: AppTextStyles.totalFundLabel.copyWith(
                        fontSize:
                            isSmallScreen ? 16.0 : null, // 작은 화면에서는 폰트 크기 줄임
                      ),
                    ),
                    const SizedBox(height: 8),
                    TotalFundCard(amount: totalFund),
                    SizedBox(height: sectionSpacing),
                    topProjects.when(
                      data: (projects) => ProjectCarousel(projects: projects),
                      loading: () => const SizedBox(
                        height: 200,
                        child: Center(
                          child: SizedBox(
                            width: 40,
                            height: 40,
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                  AppColors.primary),
                            ),
                          ),
                        ),
                      ),
                      error: (error, stack) => Center(
                        child: Text('Error: $error'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
