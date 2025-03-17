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

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text(
                      AppStrings.appName,
                      style: AppTextStyles.mainTitle.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _currentTime,
                      style: AppTextStyles.timeStyle,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      AppStrings.totalFund,
                      style: AppTextStyles.totalFundLabel,
                    ),
                    const SizedBox(height: 8),
                    TotalFundCard(amount: totalFund),
                    const SizedBox(height: 24),
                    topProjects.when(
                      data: (projects) => ProjectCarousel(projects: projects),
                      loading: () =>
                          const Center(child: CircularProgressIndicator()),
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
