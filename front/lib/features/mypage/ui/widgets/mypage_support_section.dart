import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:front/core/services/api_service.dart';
import 'package:front/core/ui/widgets/app_dialog.dart';
import 'package:front/utils/logger_util.dart';
import 'package:go_router/go_router.dart';
import 'package:front/core/providers/app_state_provider.dart';
import 'package:front/features/mypage/ui/view_model/profile_view_model.dart';
import 'package:front/features/mypage/ui/view_model/total_funding_provider.dart';
import 'package:front/features/wishlist/ui/view_model/wishlist_view_model.dart';
import 'package:front/features/auth/providers/auth_providers.dart';
import 'package:dio/dio.dart';

class CustomerSupportSection extends ConsumerWidget {
  const CustomerSupportSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 섹션 타이틀
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 20, 16, 8),
          child: Text(
            "고객지원",
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),

        const Divider(height: 1, thickness: 1, color: Colors.grey),

        _buildLogoutItem(context, ref),
        _buildSupportItem(context, title: "자주 물어보는 Q&A", route: '/support/faq'),
        _buildSupportItem(context, title: "공지사항", route: '/support/notice'),
        _buildSupportItem(context, title: "앱 사용 가이드", route: '/support/guide'),
        _buildSupportItem(context,
            title: "이용약관 / 개인정보 처리방침", route: '/support/policy'),

        // 구분선
        const Divider(height: 1, thickness: 1, color: Colors.grey),

        // 고객센터 정보
        _buildInfoItem("고객센터", "000-0000"),
        _buildInfoItem("버전 정보", "v1.0.0"),
      ],
    );
  }

  // 로그아웃 항목 (모달 띄우기)
  Widget _buildLogoutItem(BuildContext context, WidgetRef ref) {
    return InkWell(
      onTap: () {
        // 로그아웃 확인 모달 띄우기
        AppDialog.show(
          context: context,
          title: "로그아웃",
          content: "정말 로그아웃 하시겠습니까?",
          confirmText: "로그아웃",
          cancelText: "취소",
          onConfirm: () async {
            // 로그아웃 처리 함수 호출 - 주의: AppDialog는 자체적으로 닫힘
            await _performLogout(context, ref);
          },
        );
      },
      child: const Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Text(
                  "로그아웃",
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1, thickness: 1, color: Colors.grey),
        ],
      ),
    );
  }

  // 로그아웃 처리 로직을 별도 함수로 분리
  Future<void> _performLogout(BuildContext context, WidgetRef ref) async {
    // 로딩 다이얼로그 컨트롤러 추가
    BuildContext? loadingContext;
    bool isLoading = false;

    // CancelToken 추가
    final cancelToken = CancelToken();

    // 로딩 표시 함수 - 안전한 방식으로 다이얼로그 표시
    void showLoading() {
      if (!isLoading && context.mounted) {
        isLoading = true;
        // Future.microtask를 사용하여 현재 빌드 사이클을 피함
        Future.microtask(() {
          if (context.mounted) {
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (dialogContext) {
                loadingContext = dialogContext;
                return const Center(
                  child: CircularProgressIndicator(),
                );
              },
            );
          }
        });
      }
    }

    // 로딩 닫기 함수 - 안전한 방식으로 다이얼로그 제거
    void hideLoading() {
      if (isLoading) {
        isLoading = false;
        try {
          // loadingContext가 있고 Navigator.pop이 가능한 경우에만 실행
          if (loadingContext != null && Navigator.canPop(loadingContext!)) {
            Navigator.of(loadingContext!).pop();
          }
          // 대체 방법: 메인 context 사용
          else if (context.mounted && Navigator.canPop(context)) {
            Navigator.of(context).pop();
          }
        } catch (e) {
          LoggerUtil.e('로딩 다이얼로그 닫기 실패', e);
          // 오류 발생시 조용히 무시 (앱 크래시 방지)
        }
      }
    }

    // 홈으로 이동 함수 - 안전하게 라우팅 처리
    void navigateToHome() {
      if (context.mounted) {
        // 즉시 홈 이동 (비동기 작업과 충돌 방지)
        context.go('/');
        LoggerUtil.i('🏠 로그아웃 후 홈 화면으로 이동 완료');
      }
    }

    try {
      showLoading();
      LoggerUtil.i('🔄 로그아웃 처리 시작');

      // 순서 변경: 먼저 로그아웃 API 호출 후 홈 화면으로 이동
      // 이렇게 하면 토큰이 있는 상태에서 API 요청이 발생함
      final success = await ref.read(authProvider.notifier).signOut();

      // 로딩 인디케이터 닫기
      hideLoading();

      // 로그아웃 API 호출 후 홈 화면으로 이동
      navigateToHome();

      // 로그아웃 성공/실패 메시지 (이미 홈 화면으로 이동한 상태)
      if (context.mounted) {
        Future.delayed(const Duration(milliseconds: 300), () {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(success ? '로그아웃 되었습니다' : '로그아웃 처리가 완료되었습니다'),
                duration: const Duration(seconds: 2),
              ),
            );
          }
        });
      }
    } catch (e) {
      LoggerUtil.e('❌ 로그아웃 처리 중 오류', e);

      // 로딩 인디케이터 닫기
      hideLoading();

      // 오류가 발생해도 홈 화면으로 이동
      if (context.mounted) {
        navigateToHome();

        // 오류 메시지 표시
        Future.delayed(const Duration(milliseconds: 300), () {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('로그아웃 중 오류가 발생했지만, 세션이 종료되었습니다'),
                duration: Duration(seconds: 2),
              ),
            );
          }
        });
      }
    } finally {
      // 최종적으로 요청 취소하여 Dio 오류 방지
      if (!cancelToken.isCancelled) {
        cancelToken.cancel('로그아웃 처리 완료로 요청 취소');
      }
    }
  }

  // 클릭 가능한 항목
  Widget _buildSupportItem(BuildContext context,
      {required String title, required String route}) {
    return InkWell(
      onTap: () => context.push(route),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, thickness: 1, color: Colors.grey),
        ],
      ),
    );
  }

  // 단순 정보 표시용
  Widget _buildInfoItem(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 15,
              color: Colors.black54,
            ),
          ),
        ],
      ),
    );
  }
}
