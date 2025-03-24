import 'package:flutter/material.dart';
import '../../../../core/ui/widgets/custom_app_bar.dart';

class WriteReviewScreen extends StatefulWidget {
  final int fundingId;

  const WriteReviewScreen({super.key, required this.fundingId});

  @override
  State<WriteReviewScreen> createState() => _WriteReviewScreenState();
}

class _WriteReviewScreenState extends State<WriteReviewScreen> {
  final TextEditingController _controller = TextEditingController();
  int _selectedRating = 5;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: '내 리뷰',
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('이 상품 어떠셨나요 ?', style: TextStyle(fontSize: 16)),

            const SizedBox(height: 12),

            // 상품 정보 카드
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '김한민 컴퍼니',
                    style: TextStyle(fontSize: 13, color: Colors.grey),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    '[노트북 보조 모니터] 모니터+ USB 허브 게임 영상 주식을 한번에!',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    '25,0000원',
                    style: TextStyle(
                        color: Colors.green, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),

                  // 별점
                  Row(
                    children: List.generate(5, (index) {
                      return IconButton(
                        onPressed: () {
                          setState(() {
                            _selectedRating = index + 1;
                          });
                        },
                        icon: Icon(
                          Icons.star,
                          color: _selectedRating > index
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
            ),

            const SizedBox(height: 24),
            const Text('어떤 점이 좋았나요 ?', style: TextStyle(fontSize: 16)),
            const SizedBox(height: 10),

            // 리뷰 입력란
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: TextField(
                controller: _controller,
                maxLines: 6,
                decoration: const InputDecoration(
                  hintText: '리뷰를 작성해주세요,',
                  border: InputBorder.none,
                ),
              ),
            ),

            const Spacer(),

            // 하단 버튼들
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      final review = _controller.text.trim();
                      if (review.isNotEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('리뷰가 저장되었습니다!')),
                        );
                        Navigator.pop(context);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFB7E800), // 연두색
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
                    onPressed: () {
                      Navigator.pop(context);
                    },
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
            ),
          ],
        ),
      ),
    );
  }
}
