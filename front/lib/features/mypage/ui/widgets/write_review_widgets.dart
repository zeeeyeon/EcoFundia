import 'package:flutter/material.dart';

/// 📦 상품 정보 카드
class ReviewProductCard extends StatelessWidget {
  final String title;
  final String description;
  final int totalPrice;
  final int selectedRating;
  final void Function(int) onRatingChanged;

  const ReviewProductCard({
    super.key,
    required this.title,
    required this.description,
    required this.totalPrice,
    required this.selectedRating,
    required this.onRatingChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            description,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '내 후원금: ₩${totalPrice.toString()}',
            style: const TextStyle(
              fontSize: 13,
              color: Colors.green,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            '별점을 선택해주세요',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: List.generate(5, (index) {
              return IconButton(
                onPressed: () => onRatingChanged(index + 1),
                icon: Icon(
                  Icons.star,
                  color: selectedRating > index
                      ? Colors.green
                      : Colors.grey.shade300,
                ),
                iconSize: 28,
                padding: EdgeInsets.zero,
              );
            }),
          ),
        ],
      ),
    );
  }
}

/// 📝 리뷰 입력 필드
class ReviewInputField extends StatelessWidget {
  final TextEditingController controller;

  const ReviewInputField({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: TextField(
        controller: controller,
        maxLines: 6,
        decoration: const InputDecoration(
          hintText: '리뷰를 작성해주세요.',
          border: InputBorder.none,
        ),
      ),
    );
  }
}

/// ✅ 등록 / 취소 버튼
class ReviewActionButtons extends StatelessWidget {
  final VoidCallback onSubmit;
  final VoidCallback onCancel;

  const ReviewActionButtons({
    super.key,
    required this.onSubmit,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: onSubmit,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFB7E800),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            child: const Text('등록'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton(
            onPressed: onCancel,
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.grey,
              side: const BorderSide(color: Colors.grey),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            child: const Text('취소'),
          ),
        ),
      ],
    );
  }
}
