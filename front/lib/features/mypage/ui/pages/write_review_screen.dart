import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/ui/widgets/custom_app_bar.dart';
import '../../data/models/write_review_request.dart';
import '../view_model/write_review_view_model.dart';
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
  Widget build(BuildContext context) {
    final reviewState = ref.watch(writeReviewViewModelProvider);

    return Scaffold(
      appBar: const CustomAppBar(
        title: '리뷰 작성',
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('이 상품 어떠셨나요 ?', style: TextStyle(fontSize: 16)),
            const SizedBox(height: 12),
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
              onSubmit: () async {
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

                await ref
                    .read(writeReviewViewModelProvider.notifier)
                    .submitReview(request);

                final result = ref.read(writeReviewViewModelProvider);
                if (result is AsyncData && result.value == true) {
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('리뷰가 저장되었습니다!')),
                  );
                  Navigator.pop(context);
                } else if (result is AsyncError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('리뷰 등록에 실패했습니다.')),
                  );
                }
              },
              onCancel: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }
}
