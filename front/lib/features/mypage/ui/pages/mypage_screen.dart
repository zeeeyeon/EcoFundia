import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:front/core/ui/widgets/loading_overlay.dart';
import 'package:front/core/ui/widgets/app_dialog.dart';
import 'package:front/core/providers/app_state_provider.dart';
import 'package:front/features/auth/providers/auth_providers.dart';
import 'package:front/utils/logger_util.dart';
import 'package:go_router/go_router.dart';

class MypageScreen extends ConsumerWidget {
  const MypageScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appState = ref.watch(appStateProvider);

    // 에러 발생 시 스낵바 표시
    if (appState.error != null) {
      Future.microtask(() {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(appState.error!)),
        );
        ref.read(appStateProvider.notifier).clearError();
      });
    }

    return LoadingOverlay(
      isLoading: appState.isLoading,
      message: '정보를 불러오는 중...',
      child: Scaffold(
        appBar: AppBar(
          title: const Text('마이페이지'),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              const Center(
                child: CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.grey,
                  child: Icon(
                    Icons.person,
                    size: 50,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Center(
                child: Text(
                  '사용자 이름',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 40),
              _buildMenuTile('내 정보 수정', Icons.settings, () {}),
              _buildMenuTile('내 주문 내역', Icons.receipt_long, () {}),
              _buildMenuTile('내 쿠폰', Icons.card_giftcard, () {}),
              _buildMenuTile('내 리뷰', Icons.rate_review, () {}),
              _buildMenuTile('로그아웃', Icons.exit_to_app, () async {
                final shouldLogout = await AppDialog.show(
                  context: context,
                  title: '로그아웃',
                  content: '정말 로그아웃 하시겠습니까?',
                  confirmText: '로그아웃',
                  cancelText: '취소',
                  type: AppDialogType.alert,
                );

                if (shouldLogout == true) {
                  final result =
                      await ref.read(authProvider.notifier).signOut();
                  if (result) {
                    LoggerUtil.i('✅ 로그아웃 완료');
                    if (context.mounted) {
                      context.go('/login');
                    }
                  }
                }
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuTile(String title, IconData icon, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
