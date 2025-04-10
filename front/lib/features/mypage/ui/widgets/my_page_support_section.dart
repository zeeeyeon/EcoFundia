import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:front/core/themes/app_colors.dart';
import 'package:front/core/themes/app_text_styles.dart';
import 'package:front/core/ui/widgets/app_dialog.dart';
import 'package:front/utils/logger_util.dart';
import 'package:go_router/go_router.dart';
import 'package:front/features/auth/providers/auth_providers.dart';
import 'package:dio/dio.dart';

class CustomerSupportSection extends ConsumerWidget {
  const CustomerSupportSection({super.key});

  final Widget _divider = const Divider(
    height: 1,
    thickness: 1,
    color: AppColors.extraLightGrey,
    indent: 16,
    endIndent: 16,
  );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
          child: Text(
            "고객지원",
            style: AppTextStyles.body2
                .copyWith(color: AppColors.grey, fontWeight: FontWeight.w600),
          ),
        ),
        _divider,
        _buildSupportItem(context,
            title: "1:1 문의",
            route: '/coming-soon',
            icon: Icons.support_agent_outlined),
        _divider,
        _buildSupportItem(context,
            title: "자주 물어보는 Q&A",
            route: '/mypage/faq',
            icon: Icons.quiz_outlined),
        _divider,
        _buildSupportItem(context,
            title: "내 정보 수정",
            route: '/mypage/profile-edit',
            icon: Icons.person_outline),
        _divider,
        _buildLogoutItem(context, ref),
        _divider,
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildLogoutItem(BuildContext context, WidgetRef ref) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: const Icon(Icons.logout, color: AppColors.grey),
      title: Text("로그아웃", style: AppTextStyles.body1.copyWith(fontSize: 16)),
      onTap: () {
        AppDialog.show(
          context: context,
          title: "로그아웃",
          content: "정말 로그아웃 하시겠습니까?",
          confirmText: "로그아웃",
          cancelText: "취소",
          onConfirm: () async {
            await _performLogout(context, ref);
          },
        );
      },
    );
  }

  Future<void> _performLogout(BuildContext context, WidgetRef ref) async {
    BuildContext? loadingContext;
    bool isLoading = false;

    final cancelToken = CancelToken();

    void showLoading() {
      if (!isLoading && context.mounted) {
        isLoading = true;
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

    void hideLoading() {
      if (isLoading) {
        isLoading = false;
        try {
          if (loadingContext != null && Navigator.canPop(loadingContext!)) {
            Navigator.of(loadingContext!).pop();
          } else if (context.mounted && Navigator.canPop(context)) {
            Navigator.of(context).pop();
          }
        } catch (e) {
          LoggerUtil.e('로딩 다이얼로그 닫기 실패', e);
        }
      }
    }

    void navigateToHome() {
      if (context.mounted) {
        context.go('/');
        LoggerUtil.i('🏠 로그아웃 후 홈 화면으로 이동 완료');
      }
    }

    try {
      showLoading();
      LoggerUtil.i('🔄 로그아웃 처리 시작');

      final success = await ref.read(authProvider.notifier).signOut();

      hideLoading();

      navigateToHome();

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

      hideLoading();

      if (context.mounted) {
        navigateToHome();

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
      if (!cancelToken.isCancelled) {
        cancelToken.cancel('로그아웃 처리 완료로 요청 취소');
      }
    }
  }

  Widget _buildSupportItem(BuildContext context,
      {required String title, required String route, required IconData icon}) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Icon(icon, color: AppColors.grey),
      title: Text(title, style: AppTextStyles.body1.copyWith(fontSize: 16)),
      trailing:
          const Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.grey),
      onTap: () => context.push(route),
    );
  }
}
