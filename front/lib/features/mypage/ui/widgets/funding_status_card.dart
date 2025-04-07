import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:front/core/themes/app_colors.dart';
import 'package:front/utils/logger_util.dart';
import 'package:front/features/mypage/ui/view_model/coupon_view_model.dart';
import 'package:front/shared/widgets/dialogs/coupon_info_dialog.dart';
import 'package:front/core/providers/app_state_provider.dart';
import 'package:front/utils/auth_utils.dart';

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

  Widget _buildStatusItem(
    BuildContext context,
    String title,
    String value, {
    bool highlight = false,
  }) {
    final textStyle = TextStyle(
      fontSize: 14,
      fontWeight: highlight ? FontWeight.bold : FontWeight.normal,
      color: highlight ? Colors.black : Colors.grey,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(title,
              style: textStyle.copyWith(
                  fontWeight: FontWeight.normal, color: Colors.grey[600])),
          const SizedBox(height: 4),
          GestureDetector(
            onTap: title == "쿠폰" ? () => context.push('/coupons') : null,
            child: Text(value, style: textStyle),
          ),
        ],
      ),
    );
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
  void _resetCouponButton() {
    if (!mounted) return;

    setState(() {
      _canClickCouponButton = true;
    });

    // 최신 쿠폰 개수 정보 갱신
    ref.refresh(couponCountProvider);

    LoggerUtil.d('🎫 쿠폰 버튼 활성화됨');
  }

  @override
  Widget build(BuildContext context) {
    // 쿠폰 개수 가져오기 (FutureProvider 사용)
    final couponCountAsync = ref.watch(couponCountProvider);

    // 쿠폰 상태 모니터링
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

    // 쿠폰 개수를 표시하는 위젯
    Widget buildCouponCount() {
      return couponCountAsync.when(
        data: (count) => Text(
          "$count장",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: count > 0 ? AppColors.primary : Colors.black,
          ),
        ),
        error: (_, __) => const Text(
          "0장",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        loading: () => const SizedBox(
          width: 15,
          height: 15,
          child: CircularProgressIndicator(
            strokeWidth: 2,
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(10),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            // 펀딩현황, 쿠폰 개수 표시 영역
            Row(
              children: [
                Expanded(
                  child: _buildStatusItem(
                    context,
                    "펀딩현황",
                    "${widget.totalFundingAmount}원",
                    highlight: true,
                  ),
                ),
                // 세로 구분선
                Container(
                  height: 60,
                  width: 1,
                  color: Colors.grey.shade300,
                ),
                Expanded(
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "쿠폰",
                          style: TextStyle(
                            fontWeight: FontWeight.normal,
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 4),
                        GestureDetector(
                          onTap: () {
                            // 쿠폰 목록 페이지로 이동하기 전에 상태 완전 초기화
                            _couponViewModel.resetState();
                            context.push('/coupons');
                          },
                          child: buildCouponCount(),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // 가로 구분선 및 쿠폰 받기 버튼 영역
            const Divider(height: 1, thickness: 1, color: Colors.grey),
            Padding(
              padding: const EdgeInsets.all(18.0),
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
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ))
                    : const Icon(Icons.card_giftcard, size: 24),
                label: Text(
                  isApplying ? '쿠폰 처리 중...' : '선착순 쿠폰 받기!',
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isApplying || !_canClickCouponButton
                      ? AppColors.primary.withOpacity(0.7)
                      : AppColors.primary,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 52),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 3,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
