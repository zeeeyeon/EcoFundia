import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:front/core/services/api_service.dart';
import 'package:front/core/ui/widgets/app_dialog.dart';
import 'package:front/utils/logger_util.dart';
import 'package:go_router/go_router.dart';

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
        // 약간의 지연 후 홈 이동 (비동기 작업과 충돌 방지)
        Future.delayed(const Duration(milliseconds: 100), () {
          if (context.mounted) {
            // 홈 화면으로 이동 (스택을 모두 비우고 이동)
            context.go('/');
          }
        });
      }
    }

    try {
      showLoading();
      LoggerUtil.i('🔄 로그아웃 처리 시작');

      // ApiService에서 로그아웃 요청 처리
      final apiService = ref.read(apiServiceProvider);
      final success = await apiService.logout();

      // 로딩 숨기기 전에 약간 지연 (UI 상태 안정화)
      await Future.delayed(const Duration(milliseconds: 300));
      hideLoading();

      if (success) {
        LoggerUtil.i('✅ 로그아웃 완료 - 홈으로 이동');
        if (context.mounted) {
          navigateToHome();

          // 스낵바는 라우팅 후 표시 (충돌 방지)
          Future.delayed(const Duration(milliseconds: 500), () {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('로그아웃 되었습니다')),
              );
            }
          });
        }
      } else {
        LoggerUtil.w('⚠️ 로그아웃 부분 실패');
        if (context.mounted) {
          navigateToHome();

          Future.delayed(const Duration(milliseconds: 500), () {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('로그아웃 처리가 완료되었습니다')),
              );
            }
          });
        }
      }
    } catch (e) {
      LoggerUtil.e('❌ 로그아웃 처리 중 오류', e);
      hideLoading();

      if (context.mounted) {
        navigateToHome();

        Future.delayed(const Duration(milliseconds: 500), () {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('로그아웃 중 오류가 발생했지만, 세션이 종료되었습니다')),
            );
          }
        });
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
