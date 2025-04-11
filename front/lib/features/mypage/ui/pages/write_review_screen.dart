import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:front/utils/logger_util.dart';
import '../../../../core/ui/widgets/custom_app_bar.dart';
import '../../data/models/write_review_request.dart';
import '../view_model/write_review_view_model.dart';
import '../view_model/my_review_view_model.dart';
import '../widgets/write_review_widgets.dart';

class WriteReviewScreen extends ConsumerStatefulWidget {
  final int fundingId;
  final String title;
  final String description;
  final int totalPrice;

  const WriteReviewScreen({
    super.key,
    required this.fundingId,
    required this.title,
    required this.description,
    required this.totalPrice,
  });

  @override
  ConsumerState<WriteReviewScreen> createState() => _WriteReviewScreenState();
}

class _WriteReviewScreenState extends ConsumerState<WriteReviewScreen> {
  final TextEditingController _controller = TextEditingController();
  int _selectedRating = 5;

  @override
  void dispose() {
    _controller.dispose();
    // addPostFrameCallback으로 감싸서 다음 프레임에 실행하도록 지연
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Provider가 여전히 유효한지 확인 (선택 사항이지만 안전)
      try {
        ref.invalidate(writeReviewViewModelProvider); // 상태 초기화
      } catch (e) {
        // Provider가 이미 dispose되었을 수 있음
        LoggerUtil.e('Error invalidating provider in dispose: $e');
      }
    });
    super.dispose();
  }

  Future<void> _validateAndSubmit() async {
    final content = _controller.text.trim();
    final rating = _selectedRating;

    if (content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('리뷰 내용을 입력해주세요.')),
      );
      return;
    }

    final request = WriteReviewRequest(
      fundingId: widget.fundingId,
      rating: rating,
      content: content,
    );

    await ref.read(writeReviewViewModelProvider.notifier).submitReview(request);
    final result = ref.read(writeReviewViewModelProvider);

    if (result is AsyncData && result.value == true) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('리뷰가 저장되었습니다!')),
      );
      ref.invalidate(myReviewProvider); // 리뷰 목록 새로고침
      Navigator.pop(context);
    } else if (result is AsyncError) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('리뷰 등록에 실패했습니다.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final reviewState = ref.watch(writeReviewViewModelProvider);

    return Scaffold(
      appBar: const CustomAppBar(
        title: '리뷰 작성',
        showBackButton: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('이 상품 어떠셨나요 ?', style: TextStyle(fontSize: 16)),
            const SizedBox(height: 12),
            const SizedBox(height: 16),
            ReviewProductCard(
              title: widget.title,
              description: widget.description,
              totalPrice: widget.totalPrice,
              selectedRating: _selectedRating,
              onRatingChanged: (rating) {
                setState(() {
                  _selectedRating = rating;
                });
              },
            ),
            const SizedBox(height: 24),
            const Text('어떤 점이 좋았나요 ?', style: TextStyle(fontSize: 16)),
            const SizedBox(height: 10),
            ReviewInputField(controller: _controller),
            const Spacer(),
            ReviewActionButtons(
              isLoading: reviewState.isLoading,
              onSubmit: _validateAndSubmit,
              onCancel: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }
}
