import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:front/core/themes/app_colors.dart';
import 'package:front/core/themes/app_text_styles.dart';
import 'package:front/features/home/domain/entities/project_entity.dart';
import 'package:front/shared/payment/ui/view_model/payment_view_model.dart';
import 'package:front/shared/payment/ui/widgets/product_info_section.dart';
import 'package:front/shared/payment/ui/widgets/payment_info_section.dart';
import 'package:front/shared/payment/ui/widgets/payment_confirm_dialog.dart';
import 'package:front/utils/logger_util.dart';
import 'package:go_router/go_router.dart';

/// 결제 페이지
class PaymentPage extends ConsumerStatefulWidget {
  /// 상품 ID
  final String productId;

  /// 상세 페이지에서 전달받은 프로젝트 정보 (API 호출 대신 사용)
  final ProjectEntity? projectEntity;

  const PaymentPage({
    Key? key,
    required this.productId,
    this.projectEntity,
  }) : super(key: key);

  @override
  ConsumerState<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends ConsumerState<PaymentPage> {
  @override
  void initState() {
    super.initState();

    // 프로젝트 정보가 전달되었는지 확인
    if (widget.projectEntity != null) {
      // 전달받은 프로젝트 정보로 결제 정보 초기화
      Future.microtask(() {
        ref
            .read(paymentViewModelProvider.notifier)
            .initializePaymentFromProject(widget.projectEntity!);
      });
    } else {
      // 기존 방식대로 API로 결제 정보 로드
      Future.microtask(() {
        ref
            .read(paymentViewModelProvider.notifier)
            .loadPaymentInfo(widget.productId);
      });
    }
  }

  // 뒤로가기 핸들러 - 제품 상세 페이지로 이동
  void _handleBack() {
    // 제품 상세 페이지로 이동
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(paymentViewModelProvider);
    final viewModel = ref.read(paymentViewModelProvider.notifier);
    final payment = state.payment;

    // 로딩 인디케이터
    if (state.isLoading) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          title: Text('결제',
              style: AppTextStyles.body1.copyWith(fontWeight: FontWeight.bold)),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: _handleBack,
          ),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    // 확인 다이얼로그 표시 (한 번만 실행되도록 처리)
    // 이전 상태와 현재 상태를 비교해서 showSuccessDialog가 false에서 true로 변경된 경우에만 표시
    if (state.showSuccessDialog && payment != null) {
      // 모달이 표시되는 동안에는 상태 변경을 방지하기 위해 즉시 상태를 업데이트
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // 이미 다이얼로그가 표시 중인지 확인
        bool isDialogShowing = false;
        Navigator.of(context).popUntil((route) {
          isDialogShowing = route is DialogRoute;
          // 다이얼로그 이외의 라우트는 유지
          return !isDialogShowing;
        });

        // 다이얼로그가 표시되고 있지 않을 때만 새로 표시
        if (!isDialogShowing) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (dialogContext) => PaymentConfirmDialog(
              amount: payment.finalAmount,
              onCancel: () {
                // 상태를 먼저 업데이트한 후 다이얼로그 닫기
                viewModel.closePaymentDialog();
                Navigator.of(dialogContext).pop();
              },
              onConfirm: () async {
                try {
                  LoggerUtil.i('결제 처리 시작');

                  // 결제 처리 시작
                  await viewModel.processPayment();

                  // 다이얼로그 닫기 (상태 업데이트 후)
                  viewModel.closePaymentDialog();
                  if (dialogContext.mounted) Navigator.of(dialogContext).pop();

                  // 에러가 없으면 결제 성공으로 처리
                  if (state.error == null) {
                    LoggerUtil.i('결제 성공 - 결제 완료 페이지로 이동');

                    // 결제 완료 페이지로 이동
                    if (context.mounted) {
                      context.go('/payment/complete');
                    }
                  } else {
                    // 결제 실패 메시지 표시
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(state.error ?? '결제 처리 중 오류가 발생했습니다.'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                } catch (e) {
                  LoggerUtil.e('결제 처리 중 예외 발생', e);

                  // 다이얼로그 닫기 (상태 업데이트 후)
                  viewModel.closePaymentDialog();
                  if (dialogContext.mounted) Navigator.of(dialogContext).pop();

                  // 오류 메시지 표시
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('결제 처리 중 오류가 발생했습니다: ${e.toString()}'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
            ),
          );
        }
      });
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          '결제',
          style: AppTextStyles.body1.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: _handleBack,
        ),
      ),
      body: state.error != null
          ? Center(child: Text(state.error!))
          : _buildContent(context),
      bottomNavigationBar: _buildBottomBar(context),
    );
  }

  /// 메인 컨텐츠
  Widget _buildContent(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 섹션 타이틀
          Text(
            '상품 정보',
            style: AppTextStyles.body1.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),

          // 상품 정보 섹션
          const ProductInfoSection(),
        ],
      ),
    );
  }

  /// 하단 결제 버튼 영역
  Widget _buildBottomBar(BuildContext context) {
    final state = ref.watch(paymentViewModelProvider);
    final viewModel = ref.read(paymentViewModelProvider.notifier);
    final payment = state.payment;

    if (payment == null) {
      return const SizedBox(height: 60);
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(13),
            offset: const Offset(0, -1),
            blurRadius: 8,
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 결제 요약 섹션
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '결제 요약',
                    style: AppTextStyles.body1.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const PaymentInfoSection(),
                ],
              ),
            ),

            // 결제하기 버튼
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    LoggerUtil.d('결제하기 버튼 클릭');
                    viewModel.startPaymentProcess();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    '결제하기',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
