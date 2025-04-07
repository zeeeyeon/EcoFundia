import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:front/core/themes/app_colors.dart';
import 'package:front/utils/logger_util.dart';

// 쿠폰 발급 API 서비스 관련 Provider
final couponApiProvider = Provider<CouponApiService>((ref) {
  return CouponApiService();
});

// 쿠폰 API 서비스 클래스
class CouponApiService {
  // 쿠폰 발급 API 호출
  Future<bool> issueSpecialCoupon() async {
    try {
      // TODO: 실제 API 호출 구현
      await Future.delayed(const Duration(seconds: 1)); // API 호출 시뮬레이션

      // 임시 로직: 50% 확률로 성공/실패 반환 (테스트용)
      final isSuccess = DateTime.now().millisecondsSinceEpoch % 2 == 0;
      LoggerUtil.d('쿠폰 발급 결과: $isSuccess');

      if (!isSuccess) {
        throw Exception('현재 발급 가능한 쿠폰이 없습니다.');
      }

      return true;
    } catch (e) {
      LoggerUtil.e('쿠폰 발급 API 호출 실패', e);
      rethrow;
    }
  }
}

class FundingStatusCard extends ConsumerWidget {
  final int totalFundingAmount;
  final int couponCount;

  const FundingStatusCard({
    super.key,
    required this.totalFundingAmount,
    required this.couponCount,
  });

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

  // 쿠폰 발급 결과 모달 표시
  void _showCouponResultDialog(
      BuildContext context, bool isSuccess, String message) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(
            isSuccess ? '쿠폰 발급 성공!' : '쿠폰 발급 실패',
            style: TextStyle(
              color: isSuccess ? AppColors.primary : Colors.red,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('확인'),
            ),
          ],
        ),
      );
    });
  }

  // 로딩 다이얼로그 표시
  Future<void> _showLoadingDialog(BuildContext context) async {
    return showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Row(
            children: [
              const CircularProgressIndicator(),
              Container(
                margin: const EdgeInsets.only(left: 16),
                child: const Text("쿠폰 발급 중..."),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
                    "$totalFundingAmount원",
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
                onPressed: () async {
                  LoggerUtil.d('쿠폰 받기 버튼 클릭!');

                  try {
                    // 로딩 다이얼로그 표시
                    if (context.mounted) {
                      await _showLoadingDialog(context);
                    }

                    // 쿠폰 발급 API 호출
                    final isSuccess =
                        await ref.read(couponApiProvider).issueSpecialCoupon();

                    // 로딩 다이얼로그 닫기 (안전하게)
                    if (context.mounted) {
                      if (Navigator.canPop(context)) {
                        Navigator.of(context).pop();
                      }
                    }

                    // 성공 모달 표시
                    if (context.mounted) {
                      _showCouponResultDialog(
                        context,
                        true,
                        '선착순 쿠폰이 발급되었습니다!\n마이페이지 > 쿠폰함에서 확인하세요.',
                      );
                    }
                  } catch (e) {
                    LoggerUtil.e('쿠폰 발급 실패', e);

                    // 로딩 다이얼로그 닫기 (안전하게)
                    if (context.mounted) {
                      if (Navigator.canPop(context)) {
                        Navigator.of(context).pop();
                      }
                    }

                    // 실패 모달 표시
                    if (context.mounted) {
                      _showCouponResultDialog(
                        context,
                        false,
                        '현재 발급 가능한 쿠폰이 없습니다.',
                      );
                    }
                  }
                },
                icon: const Icon(Icons.card_giftcard, size: 24),
                label: const Text(
                  '선착순 쿠폰 받기!',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
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
