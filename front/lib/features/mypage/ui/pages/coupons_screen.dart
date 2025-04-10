import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:front/core/themes/app_colors.dart';
import 'package:front/features/mypage/ui/view_model/coupon_view_model.dart';
import 'package:front/features/mypage/ui/widgets/coupon_card.dart';
import 'package:front/utils/logger_util.dart';
import 'package:front/core/ui/widgets/app_dialog.dart';
import 'package:front/shared/utils/error_handler.dart';
import 'package:front/features/mypage/domain/entities/coupon_apply_result.dart';

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

    // --- ★★★ 모달 이벤트 리스너 추가 ★★★ ---
    ref.listen<CouponModalEvent>(
      couponViewModelProvider.select((state) => state.modalEvent),
      (previous, next) {
        if (next != CouponModalEvent.none) {
          _showCouponResultDialog(context, ref, next);
          // 모달 표시 후 ViewModel의 이벤트 초기화 호출
          ref.read(couponViewModelProvider.notifier).clearModalEvent();
        }
      },
    );
    // --- ★★★ 리스너 추가 끝 ★★★ ---

    // --- ★★★ 오류 상태 리스너 추가 ★★★ ---
    ref.listen<dynamic>(
      couponViewModelProvider.select((state) => state.error),
      (previous, next) {
        // 새로운 오류가 발생했을 때만 처리 (null이 아니고 이전 오류와 다를 때)
        if (next != null && previous != next) {
          ErrorHandler.handleError(context, next,
              operationDescription: '쿠폰 관련 작업');
          // 오류 처리 후 ViewModel의 오류 상태 초기화
          ref.read(couponViewModelProvider.notifier).clearError();
        }
      },
    );
    // --- ★★★ 리스너 추가 끝 ★★★ ---

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
            // ErrorHandler가 다이얼로그를 보여주므로, 여기서는 간단한 메시지나 재시도 UI만 표시
            LoggerUtil.e('🎫 쿠폰 목록 로드 오류 (FutureProvider)', error, stackTrace);
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
                  const Text('오류가 발생했습니다. 아래로 당겨 새로고침 해주세요.'),
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

  // --- ★★★ 모달 표시 함수 추가 ★★★ ---
  void _showCouponResultDialog(
      BuildContext context, WidgetRef ref, CouponModalEvent event) {
    String title;
    String content;
    AppDialogType dialogType;

    // ViewModel에서 error 객체를 가져오도록 수정
    final error = ref.read(couponViewModelProvider).error;

    switch (event) {
      case CouponModalEvent.success:
        title = '성공';
        content = '쿠폰이 발급되었습니다!';
        dialogType = AppDialogType.success;
        break;
      case CouponModalEvent.alreadyIssued:
        title = '알림';
        // error 객체가 AlreadyIssuedFailure 타입일 경우 해당 메시지 사용
        content =
            (error is AlreadyIssuedFailure) ? error.message : '이미 발급받은 쿠폰입니다.';
        dialogType = AppDialogType.info;
        break;
      case CouponModalEvent.needLogin:
        title = '로그인 필요';
        // error 객체가 AuthorizationFailure 타입일 경우 해당 메시지 사용
        content = (error is AuthorizationFailure)
            ? error.message
            : '쿠폰을 받으려면 로그인이 필요합니다.';
        dialogType = AppDialogType.warning;
        // 여기서 로그인 화면으로 보내는 로직 추가 가능
        // context.push('/login');
        break;
      case CouponModalEvent.timeLimit:
        title = '발급 불가';
        // error 객체가 CouponTimeLimitFailure 타입일 경우 해당 메시지 사용
        content = (error is CouponTimeLimitFailure)
            ? error.message
            : '지금은 쿠폰을 발급받을 수 없는 시간입니다.';
        dialogType = AppDialogType.warning;
        break;
      case CouponModalEvent
            .error: // 일반 오류는 ErrorHandler가 처리하므로 이 케이스는 제거하거나 다른 방식으로 처리
      default: // CouponModalEvent.none 또는 예기치 않은 경우
        // ErrorHandler가 이미 처리했을 것이므로 여기서는 별도 처리가 필요 없을 수 있음
        // 또는 fallback 메시지 표시
        LoggerUtil.w('예상치 못한 CouponModalEvent: $event');
        // 여기서 바로 return 하거나, 기본 메시지를 표시할 수 있음
        // return;
        title = '알림';
        content = '작업 중 문제가 발생했습니다.';
        dialogType = AppDialogType.info; // 에러 대신 정보성으로 표시
        break;
    }

    // 위젯 트리 빌드가 완료된 후 다이얼로그 표시
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (context.mounted) {
        // context 유효성 검사
        AppDialog.show(
          context: context,
          title: title,
          content: content,
          type: dialogType,
          confirmText: '확인',
          // 에러 외에는 확인 버튼만 표시 (AppDialog 기본 동작)
        );
      }
    });
  }
  // --- ★★★ 함수 추가 끝 ★★★ ---

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
