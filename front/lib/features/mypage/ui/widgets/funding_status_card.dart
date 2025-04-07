import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:front/core/themes/app_colors.dart';
import 'package:front/utils/logger_util.dart';
import 'package:front/features/mypage/ui/view_model/coupon_view_model.dart';
import 'package:front/shared/widgets/dialogs/coupon_info_dialog.dart';
import 'package:front/core/providers/app_state_provider.dart'; // 로그인 상태 확인용
import 'package:front/utils/auth_utils.dart'; // AuthUtils 추가

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
  // 마지막 처리된 모달 이벤트 추적 (중복 처리 방지)
  CouponModalEvent? _lastProcessedModalEvent;
  // ViewModel 인스턴스 저장 (dispose에서 안전하게 사용하기 위함)
  late final couponViewModel;

  @override
  void initState() {
    super.initState();

    // ViewModel 인스턴스 저장
    couponViewModel = ref.read(couponViewModelProvider.notifier);

    try {
      LoggerUtil.d('🎫 FundingStatusCard: initState 실행');

      // 캐시된 쿠폰 수 확인
      final couponState = ref.read(couponViewModelProvider);
      DateTime? lastUpdated;

      try {
        lastUpdated = couponState.lastUpdated;
        LoggerUtil.d('🎫 마지막 쿠폰 개수 업데이트 시간: $lastUpdated');
      } catch (e) {
        LoggerUtil.e('🎫 마지막 쿠폰 업데이트 확인 중 오류', e);
      }

      // 마이페이지 진입 시 항상 최신 쿠폰 개수를 보여주기 위해 쿠폰 개수 로드
      // 초기 진입 시에는 무조건 로드하도록 강제 새로고침 옵션 추가
      _loadCouponCount(forceRefresh: true);
      LoggerUtil.d('🎫 FundingStatusCard: 쿠폰 개수 강제 새로고침 요청');
    } catch (e) {
      LoggerUtil.e('쿠폰 초기화 중 오류 발생', e);
      // 오류가 발생해도 UI가 깨지지 않게 쿠폰 개수를 로드
      _loadCouponCount(forceRefresh: true);
    }
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
      // 저장된 인스턴스 사용
      couponViewModel.clearModalEvent();
      LoggerUtil.d('🎫 FundingStatusCard: dispose 시 모달 이벤트 초기화');
    } catch (e) {
      // 오류 무시 (이미 제거된 경우)
    }
    super.dispose();
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

  // 쿠폰 개수 로드
  void _loadCouponCount({bool forceRefresh = false}) {
    ref
        .read(couponViewModelProvider.notifier)
        .loadCouponCount(forceRefresh: forceRefresh);
  }

  @override
  Widget build(BuildContext context) {
    // 쿠폰 ViewModel 사용 - 필요한 부분만 select로 가져오기
    final couponCount = ref.watch(
      couponViewModelProvider.select((state) => state.couponCount),
    );

    // UI에 영향을 주는 상태만 watch
    final isApplying = ref.watch(
      couponViewModelProvider.select((state) => state.isApplying),
    );

    // 모달 이벤트 상태 감지 (위젯 리빌드 시 항상 체크)
    final modalEvent = ref.watch(
      couponViewModelProvider.select((state) => state.modalEvent),
    );

    // 모달 이벤트 리스너 추가
    ref.listen(couponViewModelProvider.select((state) => state.modalEvent),
        (previous, next) {
      if (!mounted) return; // mounted 체크 추가

      LoggerUtil.d('🎫 모달 이벤트 감지: $next');

      if (next == CouponModalEvent.none || next == previous) {
        return; // 이벤트가 없거나 이전과 동일하면 무시
      }

      // 마지막으로 처리된 이벤트와 동일해도 무시 (중복 처리 방지)
      if (next == _lastProcessedModalEvent) {
        LoggerUtil.d('🎫 FundingStatusCard: 이미 처리된 모달 이벤트 무시 ($next)');
        return;
      }

      // 처리할 이벤트 기록
      _lastProcessedModalEvent = next;
      LoggerUtil.d('🎫 FundingStatusCard: 모달 이벤트 처리 시작 - $next');

      // 모달 이벤트 처리
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) {
          LoggerUtil.w('🎫 FundingStatusCard: 위젯이 마운트되지 않아 모달 표시 불가');
          return;
        }

        LoggerUtil.i('🎫 FundingStatusCard: 모달 다이얼로그 표시 시작 - $next');

        switch (next) {
          case CouponModalEvent.success:
            LoggerUtil.i('🎫 쿠폰 발급 성공 모달 표시');
            showCouponSuccessDialog(context);
            break;

          case CouponModalEvent.alreadyIssued:
            LoggerUtil.i('🎫 쿠폰 이미 발급됨 모달 표시');
            showAlreadyIssuedCouponDialog(context);
            break;

          case CouponModalEvent.needLogin:
            LoggerUtil.i('🎫 로그인 필요 모달 표시');
            showLoginRequiredDialog(context);
            break;

          case CouponModalEvent.error:
            LoggerUtil.i('🎫 쿠폰 발급 오류 모달 표시');
            showCouponErrorDialog(
                context, ref.read(couponViewModelProvider).errorMessage);
            break;

          default:
            break;
        }

        // 모달 이벤트 초기화
        Future.delayed(const Duration(milliseconds: 300), () {
          if (mounted) {
            try {
              ref.read(couponViewModelProvider.notifier).clearModalEvent();
            } catch (e) {
              LoggerUtil.e('🎫 모달 이벤트 초기화 실패', e);
            }
          }
        });
      });
    });

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
                  child: _buildStatusItem(
                    context,
                    "쿠폰",
                    "$couponCount장",
                    highlight: true,
                  ),
                ),
              ],
            ),

            // 가로 구분선 및 쿠폰 받기 버튼 영역
            const Divider(height: 1, thickness: 1, color: Colors.grey),
            Padding(
              padding: const EdgeInsets.all(18.0),
              child: ElevatedButton.icon(
                onPressed: isApplying
                    ? null // 로딩 중이면 버튼 비활성화
                    : () async {
                        LoggerUtil.d('🎫 FundingStatusCard: 쿠폰 버튼 클릭됨');

                        // AuthUtils를 사용하여 로그인 상태 확인 및 모달 표시
                        final isAuthenticated =
                            await AuthUtils.checkAuthAndShowModal(
                          context,
                          ref,
                          AuthRequiredFeature.funding,
                          showModal: true,
                        );

                        if (!isAuthenticated) {
                          LoggerUtil.d(
                              '🎫 FundingStatusCard: 인증되지 않은 사용자, 쿠폰 발급 취소');
                          return;
                        }

                        LoggerUtil.d('🎫 FundingStatusCard: 인증된 사용자, 쿠폰 발급 진행');
                        try {
                          // ViewModel의 applyCoupon 메서드 직접 호출
                          await ref
                              .read(couponViewModelProvider.notifier)
                              .applyCoupon();
                          LoggerUtil.d('🎫 쿠폰 발급 API 호출 완료');
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
                      },
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
                  backgroundColor: isApplying
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
