import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:front/core/constants/app_strings.dart';
import 'package:front/core/themes/app_colors.dart';
import 'package:front/core/themes/app_text_styles.dart';
import 'package:front/features/home/ui/view_model/home_view_model.dart';
import 'package:front/utils/logger_util.dart';
import 'package:intl/intl.dart';

/// 총 펀딩 금액을 표시하는 위젯
/// 애니메이션 효과와 WebSocket 연결 상태를 함께 표시합니다
class TotalFundDisplay extends ConsumerStatefulWidget {
  const TotalFundDisplay({Key? key}) : super(key: key);

  @override
  ConsumerState<TotalFundDisplay> createState() => _TotalFundDisplayState();
}

class _TotalFundDisplayState extends ConsumerState<TotalFundDisplay>
    with SingleTickerProviderStateMixin {
  // 애니메이션 컨트롤러
  late AnimationController _animationController;

  // 금액 표시에 사용되는 변수들
  int _currentAmount = 0;
  int _previousAmount = 0;

  // 천 단위 구분자 포맷팅을 위한 formatter
  final NumberFormat _formatter = NumberFormat('#,##0');

  // Widget 라이프사이클 관리를 위한 플래그
  bool _isFirstLoad = true;
  bool _isControllerInitialized = false;

  // 애니메이션 지속 시간
  static const _animationDuration = Duration(milliseconds: 800);

  @override
  void initState() {
    super.initState();

    // 애니메이션 컨트롤러 초기화는 빌드 완료 후에 수행
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _initAnimationController();
    });
  }

  /// 애니메이션 컨트롤러 초기화
  void _initAnimationController() {
    if (_isControllerInitialized) return;

    _animationController = AnimationController(
      duration: _animationDuration,
      vsync: this,
    );

    // 애니메이션 완료 콜백
    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed && mounted) {
        setState(() {}); // 애니메이션 완료 후 상태 업데이트
      }
    });

    _isControllerInitialized = true;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // 최초 한 번만 타이머 재시작
    if (_isFirstLoad) {
      _isFirstLoad = false;

      // 빌드 사이클 이후에 실행하여 빌드 중 상태 변경 방지
      Future.microtask(() {
        if (!mounted) return;
        ref.read(homeViewModelProvider.notifier).refreshData();
      });
    }
  }

  @override
  void dispose() {
    // 애니메이션 컨트롤러 정리
    if (_isControllerInitialized) {
      _animationController.stop();
      _animationController.dispose();
    }
    super.dispose();
  }

  /// 금액을 표시 형식으로 변환 (천 단위 구분자)
  String _formatAmount(int amount) {
    return _formatter.format(amount);
  }

  /// 금액 표시 위젯 (슬롯 머신 효과)
  Widget _buildAmountDisplay() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        // 금액 (애니메이션)
        _buildAnimatingNumber(),

        // 원 단위 표시
        Text(
          '원',
          style: AppTextStyles.body.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  /// 애니메이션되는 숫자 위젯
  Widget _buildAnimatingNumber() {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        // 애니메이션 진행에 따라 이전 금액과 새 금액 사이를 보간
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

  /// WebSocket 연결 상태 아이콘
  Widget _buildWebSocketStatusIcon(bool isConnected) {
    return Tooltip(
      message: isConnected ? '실시간 업데이트 연결됨' : '실시간 업데이트 미연결',
      child: Icon(
        isConnected ? Icons.wifi : Icons.wifi_off,
        size: 16,
        color: isConnected ? AppColors.success : AppColors.grey,
      ),
    );
  }

  /// 로딩 상태 위젯
  Widget _buildLoadingState() {
    return const SizedBox(
      height: 30,
      width: 30,
      child: CircularProgressIndicator.adaptive(
        strokeWidth: 2.5,
        valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
      ),
    );
  }

  /// 에러 상태 위젯
  Widget _buildErrorState(String errorMessage) {
    return Text(
      errorMessage,
      style: AppTextStyles.caption.copyWith(
        color: AppColors.error,
        fontSize: 14,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // HomeViewModel에서 상태 가져오기
    final homeState = ref.watch(homeViewModelProvider);

    // 디버그 로깅
    LoggerUtil.d('TotalFundDisplay build: isLoading=${homeState.isLoading}, '
        'error=${homeState.error}, totalFund=${homeState.totalFund}, '
        'isWebSocketConnected=${homeState.isWebSocketConnected}');

    // 애니메이션 컨트롤러 초기화 확인
    if (!_isControllerInitialized) {
      _initAnimationController();
    }

    // 금액이 변경되었을 때만 애니메이션 실행
    if (_isControllerInitialized &&
        homeState.totalFund != _currentAmount &&
        !homeState.isLoading) {
      _previousAmount = _currentAmount;
      _currentAmount = homeState.totalFund;

      LoggerUtil.d('Fund amount changed: $_previousAmount -> $_currentAmount');
      _animationController.forward(from: 0.0);
    }

    // 총 펀딩 금액 또는 로딩/에러 상태 표시 로직 개선
    Widget displayContent;
    if (homeState.error != null && !homeState.isLoading) {
      // 로딩 중이 아닐 때만 에러 표시
      // 에러 상태일 때는 금액 표시 대신 에러 메시지 표시
      displayContent = _buildErrorState(homeState.error!);
      LoggerUtil.w(
          'TotalFundDisplay - Error state: ${homeState.error}'); // 에러 로깅 추가
    } else if (homeState.isLoading && _currentAmount == 0) {
      // 초기 로딩 상태
      displayContent = _buildLoadingState();
      LoggerUtil.d('TotalFundDisplay - Initial loading state');
    } else {
      // 정상 상태 또는 로딩 중(금액 애니메이션은 이전 값으로 표시될 수 있음)
      displayContent = _buildAmountDisplay();
      LoggerUtil.d('TotalFundDisplay - Displaying amount');
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 제목 행: 'TOTAL FUND'와 WebSocket 상태 아이콘
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              AppStrings.totalFund,
              style: AppTextStyles.caption.copyWith(
                color: AppColors.grey,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 6),
            _buildWebSocketStatusIcon(homeState.isWebSocketConnected),
          ],
        ),

        const SizedBox(height: 8),

        // 총 펀딩 금액 또는 로딩/에러 상태 표시
        displayContent, // 위에서 결정된 위젯 사용
      ],
    );
  }
}
