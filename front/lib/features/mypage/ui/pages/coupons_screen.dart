import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:front/core/themes/app_colors.dart';
import 'package:front/features/mypage/ui/view_model/coupon_view_model.dart';
import 'package:front/features/mypage/ui/widgets/coupon_card.dart';

class CouponsScreen extends ConsumerStatefulWidget {
  const CouponsScreen({super.key});

  @override
  ConsumerState<CouponsScreen> createState() => _CouponsScreenState();
}

class _CouponsScreenState extends ConsumerState<CouponsScreen> {
  bool _isFirstLoad = true;
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();

    // 쿠폰 목록 로드 (최초 한번만)
    Future.microtask(() {
      if (_isFirstLoad) {
        _isFirstLoad = false;
        ref.read(couponViewModelProvider.notifier).loadCouponList();
      }
    });
  }

  // 새로고침 처리 함수
  Future<void> _handleRefresh() async {
    // 이미 새로고침 중이면 중복 실행 방지
    if (_isRefreshing) return;

    setState(() {
      _isRefreshing = true;
    });

    try {
      await ref.read(couponViewModelProvider.notifier).loadCouponList();
    } finally {
      if (mounted) {
        setState(() {
          _isRefreshing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final couponState = ref.watch(couponViewModelProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('내 쿠폰함'),
        centerTitle: true,
        backgroundColor: Colors.white,
      ),
      body: RefreshIndicator(
        onRefresh: _handleRefresh,
        child: _buildCouponContent(couponState),
      ),
    );
  }

  Widget _buildCouponContent(CouponState state) {
    // 로딩 중인 경우
    if (state.isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    // 에러가 있는 경우
    if (state.errorMessage.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              color: Colors.red,
              size: 60,
            ),
            const SizedBox(height: 16),
            Text(
              '오류가 발생했습니다',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(state.errorMessage),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _handleRefresh,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              child: const Text('다시 시도'),
            ),
          ],
        ),
      );
    }

    // 쿠폰이 없는 경우
    if (state.coupons.isEmpty) {
      return _buildEmptyCouponsView();
    }

    // 쿠폰 목록 표시
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: state.coupons.length,
      itemBuilder: (context, index) {
        final coupon = state.coupons[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: CouponCard(coupon: coupon),
        );
      },
    );
  }

  // 쿠폰이 없을 때 표시할 화면
  Widget _buildEmptyCouponsView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.card_giftcard,
            color: Colors.grey,
            size: 60,
          ),
          const SizedBox(height: 16),
          Text(
            '보유한 쿠폰이 없습니다',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          const Text('마이페이지에서 선착순 쿠폰을 받아보세요!'),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop(); // 마이페이지로 돌아가기
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('마이페이지로 돌아가기'),
          ),
        ],
      ),
    );
  }
}
