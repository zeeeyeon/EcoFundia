import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:front/core/themes/app_colors.dart';
import 'package:front/core/themes/app_text_styles.dart';
import 'package:front/utils/logger_util.dart';
import 'package:front/features/mypage/ui/view_model/coupon_view_model.dart';
import 'package:front/shared/widgets/dialogs/coupon_info_dialog.dart';
import 'package:front/core/providers/app_state_provider.dart';
import 'package:front/utils/auth_utils.dart';
import 'package:intl/intl.dart';

/// 쿠폰 초기화 상태 관리를 위한 Provider
final couponInitializedProvider = StateProvider<bool>((ref) => false);

// ConsumerWidget -> ConsumerStatefulWidget으로 변경
class FundingStatusCard extends ConsumerStatefulWidget {
  final int totalFundingAmount;
  final bool isApplying;

  const FundingStatusCard({
    super.key,
    required this.totalFundingAmount,
    this.isApplying = false,
  });

  @override
  ConsumerState<FundingStatusCard> createState() => _FundingStatusCardState();
}

class _FundingStatusCardState extends ConsumerState<FundingStatusCard> {
  // ViewModel 인스턴스 저장
  late final CouponViewModel _couponViewModel;
  // 쿠폰 버튼 클릭 방지 타이머
  Timer? _clickDebounceTimer;
  // 쿠폰 버튼 클릭 가능 여부
  bool _canClickCouponButton = true;

  @override
  void initState() {
    super.initState();
    _couponViewModel = ref.read(couponViewModelProvider.notifier);

    // 위젯 빌드 후 쿠폰 데이터 로드 (일회성 작업)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final isInitialized = ref.read(couponInitializedProvider);
      if (!isInitialized) {
        LoggerUtil.d('🎫 FundingStatusCard: 쿠폰 데이터 초기화 진행');
        _loadCouponData();
        ref.read(couponInitializedProvider.notifier).state = true;
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    LoggerUtil.d('🎫 FundingStatusCard: didChangeDependencies 호출됨');
  }

  @override
  void dispose() {
    // 위젯이 dispose될 때 모달 이벤트 초기화
    // 페이지를 떠날 때 쿠폰 모달이 다른 화면에서 표시되는 것을 방지
    try {
      _couponViewModel.clearModalEvent();
      LoggerUtil.d('🎫 FundingStatusCard: dispose 시 모달 이벤트 초기화');
    } catch (e) {
      // 오류 무시 (이미 제거된 경우)
    }
    _clickDebounceTimer?.cancel();
    super.dispose();
  }

  /// 쿠폰 데이터 로드
  Future<void> _loadCouponData() async {
    try {
      LoggerUtil.d('🎫 FundingStatusCard: couponCountProvider를 통한 쿠폰 개수 로드 시작');
      // Future Provider를 사용하여 쿠폰 개수 로드 (안전한 상태 관리)
      final count = await ref.refresh(couponCountProvider.future);
      LoggerUtil.d('🎫 FundingStatusCard: 쿠폰 개수 로드 완료 - $count개');
    } catch (e) {
      LoggerUtil.e('🎫 FundingStatusCard: 쿠폰 개수 로드 실패', e);
      // 오류가 발생해도 UI 처리는 AsyncValue를 통해 자동으로 처리됨
    }
  }

  // 쿠폰 발급 처리
  Future<void> _handleCouponApply() async {
    if (!_canClickCouponButton) {
      LoggerUtil.d('🎫 쿠폰 버튼 클릭 무시: 디바운스 중');
      return;
    }

    LoggerUtil.d('🎫 FundingStatusCard: 쿠폰 버튼 클릭됨');

    // 클릭 방지 설정 (2초 동안 중복 클릭 방지)
    _canClickCouponButton = false;
    _clickDebounceTimer?.cancel();
    _clickDebounceTimer = Timer(const Duration(seconds: 2), () {
      _canClickCouponButton = true;
    });

    try {
      // AuthUtils를 사용하여 로그인 상태 확인 및 모달 표시
      final isAuthenticated = await AuthUtils.checkAuthAndShowModal(
        context,
        ref,
        AuthRequiredFeature.funding,
        showModal: true,
      );

      if (!isAuthenticated) {
        LoggerUtil.d('🎫 FundingStatusCard: 인증되지 않은 사용자, 쿠폰 발급 취소');
        return;
      }

      LoggerUtil.d('🎫 FundingStatusCard: 인증된 사용자, 쿠폰 발급 진행');

      // 모달 이벤트 초기화 (이전 상태 제거)
      _couponViewModel.clearModalEvent();

      // ViewModel의 applyCoupon 메서드 직접 호출
      await _couponViewModel.applyCoupon();
      LoggerUtil.d('🎫 쿠폰 발급 API 호출 완료');

      // 쿠폰 개수 갱신
      final updatedCount = await ref.refresh(couponCountProvider.future);
      LoggerUtil.d('🎫 쿠폰 발급 후 개수 갱신 완료: $updatedCount개');
    } catch (e) {
      LoggerUtil.e('🎫 쿠폰 발급 중 예외 발생', e);

      // 에러 발생 시 스낵바로 알림
      if (mounted && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('쿠폰 발급 중 오류가 발생했습니다. 다시 시도해주세요.'),
            duration: Duration(seconds: 3),
          ),
        );
      }
    }
  }

  // 모달 이벤트 처리
  void _handleModalEvent(CouponModalEvent event) {
    if (!mounted || !context.mounted) return;

    LoggerUtil.d('🎫 FundingStatusCard: 모달 이벤트 처리 - $event');

    try {
      switch (event) {
        case CouponModalEvent.success:
          LoggerUtil.i('🎫 쿠폰 발급 성공 모달 표시');
          showCouponSuccessDialog(context).then((_) {
            // 모달이 닫힌 후 버튼 다시 활성화
            _resetCouponButton();
          });
          break;

        case CouponModalEvent.alreadyIssued:
          LoggerUtil.i('🎫 쿠폰 이미 발급됨 모달 표시');
          showAlreadyIssuedCouponDialog(context).then((_) {
            // 모달이 닫힌 후 버튼 다시 활성화
            _resetCouponButton();
          });
          break;

        case CouponModalEvent.needLogin:
          LoggerUtil.i('🎫 로그인 필요 모달 표시');
          showLoginRequiredDialog(context).then((_) {
            // 모달이 닫힌 후 버튼 다시 활성화
            _resetCouponButton();
          });
          break;

        case CouponModalEvent.error:
          LoggerUtil.i('🎫 쿠폰 발급 오류 모달 표시');
          showCouponErrorDialog(
                  context, ref.read(couponViewModelProvider).errorMessage)
              .then((_) {
            // 모달이 닫힌 후 버튼 다시 활성화
            _resetCouponButton();
          });
          break;

        default:
          LoggerUtil.d('🎫 처리할 모달 이벤트 없음');
          break;
      }

      // 모달 이벤트 초기화를 지연시켜 처리
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) {
          try {
            _couponViewModel.clearModalEvent();
            LoggerUtil.d('🎫 모달 이벤트 초기화 완료');
          } catch (e) {
            LoggerUtil.e('🎫 모달 이벤트 초기화 실패', e);
          }
        }
      });
    } catch (e) {
      LoggerUtil.e('🎫 모달 이벤트 처리 중 오류 발생', e);
      // 오류 발생 시에도 모달 이벤트 초기화 시도
      if (mounted) {
        try {
          _couponViewModel.clearModalEvent();
          _resetCouponButton(); // 오류 발생해도 버튼 초기화 시도
        } catch (clearError) {
          LoggerUtil.e('🎫 모달 이벤트 초기화 실패', clearError);
        }
      }
    }
  }

  // 쿠폰 버튼 초기화 함수 (버튼 활성화)
  void _resetCouponButton() async {
    if (!mounted) return;

    setState(() {
      _canClickCouponButton = true;
    });

    // 최신 쿠폰 개수 정보 갱신
    final updatedCount = await ref.refresh(couponCountProvider.future);
    LoggerUtil.d('🎫 쿠폰 버튼 활성화됨, 현재 쿠폰 개수: $updatedCount장');
  }

  // Helper to format currency consistently
  String _formatAmount(int amount) {
    return NumberFormat('#,###').format(amount);
  }

  @override
  Widget build(BuildContext context) {
    final couponCountAsync = ref.watch(couponCountProvider);
    final isApplying = ref.watch(
      couponViewModelProvider.select((state) => state.isApplying),
    );

    // 모달 이벤트 리스너 추가
    ref.listen(couponViewModelProvider.select((state) => state.modalEvent),
        (previous, next) {
      if (!mounted) return; // mounted 체크 추가

      LoggerUtil.d('🎫 모달 이벤트 감지: $next');

      if (next == CouponModalEvent.none) {
        return; // 이벤트가 없으면 무시
      }

      // 이전과 동일한 이벤트면 무시하지 않고 처리 (버그 수정)
      // 마지막으로 처리된 이벤트와 동일해도 처리 (이미 발급 모달도 항상 보여주기)
      LoggerUtil.d('🎫 FundingStatusCard: 모달 이벤트 처리 시작 - $next');

      // 모달 이벤트 처리
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || !context.mounted) {
          LoggerUtil.w('🎫 FundingStatusCard: 위젯이 마운트되지 않아 모달 표시 불가');
          return;
        }

        _handleModalEvent(next);
      });
    });

    // Build Coupon Count Text with consistent style
    Widget buildCouponCountText(AsyncValue<int> countAsync) {
      return countAsync.when(
        data: (count) => Text(
          "$count장",
          style: AppTextStyles.heading4.copyWith(
            fontWeight: FontWeight.bold,
            color: count > 0 ? AppColors.primary : AppColors.textDark,
            height: 1.2,
          ),
        ),
        error: (_, __) => Text(
          "0장",
          style: AppTextStyles.heading4.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.textDark,
            height: 1.2,
          ),
        ),
        loading: () => const SizedBox(
          width: 15,
          height: 15,
          child: CircularProgressIndicator(
              strokeWidth: 2, color: AppColors.primary),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Container(
        decoration: BoxDecoration(
          // Use consistent border radius and color
          borderRadius: BorderRadius.circular(12.0),
          border:
              Border.all(color: AppColors.lightGrey.withOpacity(0.5), width: 1),
          color: AppColors.white,
          boxShadow: [
            // Use subtle shadow
            BoxShadow(
              color: AppColors.shadowColor.withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            // Top section with Funding Status and Coupons
            IntrinsicHeight(
              // Make sure divider height matches content
              child: Row(
                children: [
                  // Funding Status Item
                  Expanded(
                    child: InkWell(
                      // Optional: Add onTap navigation if needed
                      // onTap: () => context.push('/my-funding'),
                      borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(12.0)),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 16, horizontal: 12),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text("펀딩현황",
                                style: AppTextStyles.body2
                                    .copyWith(color: AppColors.grey)),
                            const SizedBox(height: 6),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.baseline,
                              textBaseline: TextBaseline.alphabetic,
                              children: [
                                Text(
                                  _formatAmount(widget
                                      .totalFundingAmount), // Formatted amount
                                  style: AppTextStyles.heading4.copyWith(
                                    color: AppColors
                                        .primary, // Primary color for amount
                                    fontWeight: FontWeight.bold,
                                    height: 1.2,
                                  ),
                                ),
                                Text("원",
                                    style: AppTextStyles.body2.copyWith(
                                        color: AppColors.primary,
                                        fontSize: 14)), // Unit
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Vertical Divider
                  Container(
                    width: 1,
                    color: AppColors.lightGrey.withOpacity(0.5),
                  ),
                  // Coupon Item
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        _couponViewModel.resetState();
                        context.push('/coupons');
                      },
                      borderRadius: const BorderRadius.only(
                          topRight: Radius.circular(12.0)),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 16, horizontal: 12),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text("쿠폰",
                                style: AppTextStyles.body2
                                    .copyWith(color: AppColors.grey)),
                            const SizedBox(height: 6),
                            buildCouponCountText(
                                couponCountAsync), // Use helper
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Restore Divider and Coupon Button Area
            Container(
                height: 1,
                color: AppColors.lightGrey.withOpacity(0.5),
                margin: const EdgeInsets.symmetric(
                    horizontal: 16)), // Add horizontal margin
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton.icon(
                onPressed: _canClickCouponButton && !isApplying
                    ? _handleCouponApply
                    : null,
                icon: isApplying
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(AppColors.white)))
                    : const Icon(Icons.card_giftcard_outlined,
                        size: 24,
                        color: AppColors.white), // Ensure icon color is white
                label: Text(
                  isApplying
                      ? '쿠폰 처리 중...'
                      : '선착순 쿠폰 받기!', // Restore button text
                  style: AppTextStyles.buttonText.copyWith(
                      color: AppColors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold), // Apply button style
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _canClickCouponButton && !isApplying
                      ? AppColors.primary
                      : AppColors.primary.withOpacity(0.7),
                  foregroundColor: AppColors.white,
                  minimumSize:
                      const Size(double.infinity, 50), // Consistent height
                  shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(12)), // Consistent radius
                  elevation: 2,
                  disabledBackgroundColor: AppColors.primary
                      .withOpacity(0.5), // Style for disabled state
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
