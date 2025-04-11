import 'package:flutter/material.dart';
import 'package:front/core/themes/app_colors.dart';
import 'package:go_router/go_router.dart';

/// 쿠폰 정보 다이얼로그 위젯
/// 쿠폰 발급 결과나 안내 사항을 표시하는 커스텀 다이얼로그
class CouponInfoDialog extends StatelessWidget {
  final String title;
  final String message;
  final IconData iconData;
  final Color iconColor;
  final VoidCallback? onConfirm;
  final String buttonText;

  const CouponInfoDialog({
    Key? key,
    this.title = '쿠폰 안내',
    required this.message,
    this.iconData = Icons.confirmation_number_outlined,
    this.iconColor = AppColors.primary,
    this.onConfirm,
    this.buttonText = '확인',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: _buildDialogContent(context),
    );
  }

  Widget _buildDialogContent(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.rectangle,
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10.0,
            offset: Offset(0.0, 5.0),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min, // 내용물에 맞게 크기 조정
        children: <Widget>[
          // 아이콘
          Icon(
            iconData,
            size: 60.0,
            color: iconColor,
          ),
          const SizedBox(height: 16.0),

          // 제목
          Text(
            title,
            style: const TextStyle(
              fontSize: 20.0,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12.0),

          // 메시지
          Text(
            message,
            style: const TextStyle(
              fontSize: 16.0,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24.0),

          // 확인 버튼
          SizedBox(
            width: double.infinity, // 전체 너비 차지
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                elevation: 2,
              ),
              onPressed: onConfirm ?? () => Navigator.of(context).pop(),
              child: Text(
                buttonText,
                style: const TextStyle(
                    fontSize: 16.0, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 이미 발급된 쿠폰 안내 다이얼로그를 표시하는 함수
Future<void> showAlreadyIssuedCouponDialog(BuildContext context) {
  return showDialog(
    context: context,
    builder: (BuildContext context) => const CouponInfoDialog(
      title: '쿠폰 안내',
      message: '이미 발급받은 쿠폰입니다.',
      iconData: Icons.info_outline,
      iconColor: AppColors.warning,
    ),
  );
}

/// 쿠폰 발급 성공 다이얼로그를 표시하는 함수
Future<void> showCouponSuccessDialog(BuildContext context) {
  return showDialog(
    context: context,
    builder: (BuildContext context) => const CouponInfoDialog(
      title: '쿠폰 발급 성공',
      message: '선착순 쿠폰이 발급되었습니다!\n마이페이지 > 쿠폰함에서 확인하세요.',
      iconData: Icons.check_circle_outline,
      iconColor: AppColors.success,
    ),
  );
}

/// 쿠폰 발급 실패 다이얼로그를 표시하는 함수
Future<void> showCouponErrorDialog(BuildContext context, String message) {
  return showDialog(
    context: context,
    builder: (BuildContext context) => CouponInfoDialog(
      title: '쿠폰 발급 실패',
      message: message,
      iconData: Icons.error_outline,
      iconColor: AppColors.error,
    ),
  );
}

/// 로그인 필요 다이얼로그를 표시하는 함수
Future<void> showLoginRequiredDialog(BuildContext context) {
  return showDialog(
    context: context,
    builder: (BuildContext context) => CouponInfoDialog(
      title: '로그인 필요',
      message: '쿠폰을 받으려면 로그인이 필요합니다.\n지금 로그인 페이지로 이동하시겠습니까?',
      iconData: Icons.login,
      iconColor: AppColors.primary,
      buttonText: '로그인 하기',
      onConfirm: () {
        Navigator.of(context).pop(); // 현재 다이얼로그 닫기

        // 미세한 딜레이 후 로그인 페이지로 이동
        Future.delayed(const Duration(milliseconds: 100), () {
          try {
            GoRouter.of(context).push('/login');
          } catch (e) {
            // 예외 발생 시 안전하게 처리
            print('로그인 페이지 이동 실패: $e');
          }
        });
      },
    ),
  );
}
