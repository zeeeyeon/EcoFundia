import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:front/core/constants/app_strings.dart';
import 'package:front/core/themes/app_colors.dart';
import 'package:front/core/themes/app_shadows.dart';
import 'package:front/core/themes/app_text_styles.dart';
import 'package:front/features/home/ui/view_model/home_view_model.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';

/// 총 펀드 금액을 표시하는 위젯
class TotalFundDisplay extends ConsumerStatefulWidget {
  const TotalFundDisplay({Key? key}) : super(key: key);

  @override
  ConsumerState<TotalFundDisplay> createState() => _TotalFundDisplayState();
}

class _TotalFundDisplayState extends ConsumerState<TotalFundDisplay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  final Logger _logger = Logger();
  int _currentAmount = 0;
  int _previousAmount = 0;
  final NumberFormat _formatter = NumberFormat('#,##0');

  @override
  void initState() {
    super.initState();

    // 애니메이션 컨트롤러 초기화
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    // 애니메이션 완료 콜백 추가
    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        // 애니메이션이 완료되면 리셋 (디바운싱 효과)
        if (mounted) setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  /// 펀드 금액 표시 형식으로 변환 (천 단위 구분자만 적용)
  String _formatAmount(int amount) {
    // 천 단위 구분자로 포맷팅
    return _formatter.format(amount);
  }

  /// 슬롯 머신 효과 위젯 구성
  Widget _buildSlotMachine() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 40, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [AppShadows.fundBox],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 애니메이션 숫자가 표시되는 컨테이너
            Expanded(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // 정적 숫자 표시
                  if (_animationController.status ==
                          AnimationStatus.dismissed ||
                      _animationController.status == AnimationStatus.completed)
                    _buildStaticNumber(),

                  // 애니메이션 숫자 표시
                  if (_animationController.status == AnimationStatus.forward)
                    _buildAnimatingNumber(),
                ],
              ),
            ),
            // 통화 표시 (원)
            Text(
              AppStrings.wonCurrency,
              style: AppTextStyles.heading2.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 애니메이션되는 숫자 위젯
  Widget _buildAnimatingNumber() {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        // 애니메이션 진행에 따라 이전 금액과 새 금액 사이를 계산
        final animatedValue = _previousAmount +
            ((_currentAmount - _previousAmount) * _animationController.value)
                .toInt();

        return Text(
          _formatAmount(animatedValue),
          style: AppTextStyles.heading2.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.w600,
          ),
        );
      },
    );
  }

  /// 정적 숫자 위젯
  Widget _buildStaticNumber() {
    return Text(
      _formatAmount(_currentAmount),
      style: AppTextStyles.heading2.copyWith(
        color: AppColors.primary,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // HomeViewModel에서 totalFund 값 가져오기
    final homeState = ref.watch(homeViewModelProvider);

    // 금액이 변경되었을 때만 애니메이션 실행
    if (homeState.totalFund != _currentAmount && !homeState.isLoading) {
      _previousAmount = _currentAmount;
      _currentAmount = homeState.totalFund;

      // 디버그 로그 추가
      _logger.d('Fund amount changed: $_previousAmount -> $_currentAmount');

      // 애니메이션 시작
      _animationController.forward(from: 0.0);
    }

    return Column(
      children: [
        // 'TOTAL FUND' 텍스트
        Text(
          AppStrings.totalFund,
          style: AppTextStyles.caption.copyWith(
            color: AppColors.grey,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 2),

        // 총 펀드 금액 표시
        homeState.isLoading
            ? const CircularProgressIndicator.adaptive()
            : homeState.error != null
                ? Text(
                    homeState.error!,
                    style:
                        AppTextStyles.caption.copyWith(color: AppColors.error),
                  )
                : _buildSlotMachine(),
      ],
    );
  }
}
