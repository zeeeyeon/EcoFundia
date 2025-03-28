import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:front/core/themes/app_colors.dart';
import 'package:front/core/themes/app_text_styles.dart';
import 'package:front/shared/payment/ui/view_model/payment_view_model.dart';
import 'package:front/shared/payment/ui/widgets/product_info_section.dart';
import 'package:front/shared/payment/ui/widgets/payment_info_section.dart';
import 'package:front/shared/payment/ui/widgets/payment_confirm_dialog.dart';
import 'package:logger/logger.dart';

/// 결제 페이지
class PaymentPage extends ConsumerStatefulWidget {
  /// 상품 ID
  final String productId;

  const PaymentPage({
    Key? key,
    required this.productId,
  }) : super(key: key);

  @override
  ConsumerState<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends ConsumerState<PaymentPage> {
  final Logger _logger = Logger();

  @override
  void initState() {
    super.initState();
    // 결제 정보 로드
    Future.microtask(() {
      ref
          .read(paymentViewModelProvider.notifier)
          .loadPaymentInfo(widget.productId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(paymentViewModelProvider);
    final viewModel = ref.read(paymentViewModelProvider.notifier);
    final payment = state.payment;

    // 확인 다이얼로그 표시
    if (state.showSuccessDialog && payment != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => PaymentConfirmDialog(
            amount: payment.finalAmount,
            onCancel: () {
              viewModel.closePaymentDialog();
              Navigator.pop(context);
            },
            onConfirm: () async {
              final result = await viewModel.processPayment();
              if (result) {
                // 다이얼로그 닫기
                Navigator.pop(context);
                // 결제 완료 페이지로 이동
                if (mounted) {
                  Navigator.pushNamed(context, '/payment/complete');
                }
              }
            },
          ),
        );
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
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : state.error != null
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
            color: Colors.black.withOpacity(0.05),
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
                    _logger.d('결제하기 버튼 클릭');
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
