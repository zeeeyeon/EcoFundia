import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:front/features/mypage/data/models/edit_review_request.dart';
import 'package:front/features/mypage/ui/view_model/edit_review_view_model.dart';
import 'package:front/features/mypage/ui/view_model/my_review_view_model.dart';
import '../../../../core/ui/widgets/custom_app_bar.dart';

class EditReviewScreen extends ConsumerStatefulWidget {
  final int reviewId;
  final int initialRating;
  final String initialContent;
  final String title;
  final String description;
  final int totalPrice;

  const EditReviewScreen({
    super.key,
    required this.reviewId,
    required this.initialRating,
    required this.initialContent,
    required this.title,
    required this.description,
    required this.totalPrice,
  });

  @override
  ConsumerState<EditReviewScreen> createState() => _EditReviewScreenState();
}

class _EditReviewScreenState extends ConsumerState<EditReviewScreen> {
  late TextEditingController _controller;
  late int _selectedRating;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialContent);
    _selectedRating = widget.initialRating;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submitEdit() async {
    final content = _controller.text.trim();
    final rating = _selectedRating;

    if (content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('리뷰 내용을 입력해주세요.')),
      );
      return;
    }

    final request = EditReviewRequest(rating: rating, content: content);

    await ref
        .read(editReviewViewModelProvider.notifier)
        .updateReview(widget.reviewId, request);

    final result = ref.read(editReviewViewModelProvider);
    if (result is AsyncData && result.value == true) {
      if (!mounted) return;
      ref.invalidate(myReviewProvider); // 리뷰 목록 갱신
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('리뷰가 수정되었습니다!')),
      );
      Navigator.pop(context);
    } else if (result is AsyncError) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('리뷰 수정에 실패했습니다.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: '리뷰 수정',
        showBackButton: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('별점을 수정해주세요', style: TextStyle(fontSize: 16)),
            const SizedBox(height: 12),
            Row(
              children: List.generate(5, (i) {
                return IconButton(
                  icon: Icon(
                    i < _selectedRating ? Icons.star : Icons.star_border,
                    color: Colors.green,
                  ),
                  onPressed: () {
                    setState(() {
                      _selectedRating = i + 1;
                    });
                  },
                );
              }),
            ),
            const SizedBox(height: 16),
            const Text('리뷰 내용', style: TextStyle(fontSize: 16)),
            const SizedBox(height: 10),
            TextField(
              controller: _controller,
              maxLines: 6,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: '리뷰 내용을 입력해주세요.',
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _submitEdit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text(
                  '수정 완료',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
