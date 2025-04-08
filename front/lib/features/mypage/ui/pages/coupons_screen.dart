import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:front/core/themes/app_colors.dart';
import 'package:front/features/mypage/ui/view_model/coupon_view_model.dart';
import 'package:front/features/mypage/ui/widgets/coupon_card.dart';
import 'package:front/utils/logger_util.dart';

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

    // 위젯 트리 빌드 후 초기화 작업 진행 (마운트 이후)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeCoupons();
    });
  }

  /// 쿠폰 데이터 초기화
  Future<void> _initializeCoupons() async {
    if (!_isFirstLoad) return;

    try {
      _isFirstLoad = false;
      LoggerUtil.d('🎫 쿠폰 화면 초기화 시작');

      // 데이터 로드 전 이전 상태 초기화
      final viewModel = ref.read(couponViewModelProvider.notifier);
      viewModel.resetState();

      // Future 방식으로 쿠폰 목록 조회
      final coupons = await ref.refresh(couponListProvider.future);

      LoggerUtil.d('🎫 쿠폰 화면 초기화 완료: ${coupons.length}개 쿠폰 로드됨');
    } catch (e) {
      LoggerUtil.e('🎫 쿠폰 화면 초기화 실패', e);
    }
  }

  /// 새로고침 처리
  Future<void> _handleRefresh() async {
    if (_isRefreshing) {
      LoggerUtil.d('🎫 이미 새로고침 중');
      return;
    }

    setState(() => _isRefreshing = true);

    try {
      LoggerUtil.d('🎫 쿠폰 목록 새로고침 시작');
      // FutureProvider를 통한 안전한 새로고침
      final coupons = await ref.refresh(couponListProvider.future);
      LoggerUtil.d('🎫 쿠폰 목록 새로고침 완료: ${coupons.length}개 쿠폰');
    } catch (e) {
      LoggerUtil.e('🎫 쿠폰 목록 새로고침 실패', e);
    } finally {
      if (mounted) {
        setState(() => _isRefreshing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // FutureProvider를 활용한 안전한 상태 관리
    final couponListAsync = ref.watch(couponListProvider);
    final errorMessage = ref
        .watch(couponViewModelProvider.select((state) => state.errorMessage));

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        title: const Text('내 쿠폰함'),
        centerTitle: true,
        backgroundColor: Colors.white,
      ),
      body: RefreshIndicator(
        onRefresh: _handleRefresh,
        child: couponListAsync.when(
          data: (coupons) {
            // 쿠폰이 없는 경우
            if (coupons.isEmpty) {
              return _buildEmptyCouponsView();
            }

            // 쿠폰 목록 표시
            return Stack(
              children: [
                ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: coupons.length,
                  itemBuilder: (context, index) {
                    final coupon = coupons[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: CouponCard(coupon: coupon),
                    );
                  },
                ),
                // 새로고침 중일 때만 오버레이 표시
                if (_isRefreshing)
                  Container(
                    color: Colors.black.withOpacity(0.1),
                    child: const Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
              ],
            );
          },
          loading: () => const Center(
            child: CircularProgressIndicator(),
          ),
          error: (error, stackTrace) {
            LoggerUtil.e('🎫 쿠폰 목록 로드 오류', error);
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
                    '쿠폰 목록을 불러올 수 없습니다',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(errorMessage.isNotEmpty
                      ? errorMessage
                      : '네트워크 연결을 확인해주세요'),
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
          },
        ),
      ),
    );
  }

  Widget _buildEmptyCouponsView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.local_activity_outlined,
            size: 60,
            color: AppColors.grey,
          ),
          const SizedBox(height: 16),
          Text(
            '보유한 쿠폰이 없습니다',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppColors.grey,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            '새로운 쿠폰을 발급받아보세요',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.grey,
                ),
          ),
        ],
      ),
    );
  }
}
