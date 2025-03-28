import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../data/models/funding_detail_model.dart';
import '../../../../core/themes/app_text_styles.dart';
import '../../../../core/themes/app_colors.dart';

class FundingDetailCard extends StatefulWidget {
  final FundingDetailModel detail;

  const FundingDetailCard({super.key, required this.detail});

  @override
  State<FundingDetailCard> createState() => _FundingDetailCardState();
}

class _FundingDetailCardState extends State<FundingDetailCard> {
  bool _showFullStory = false;

  @override
  Widget build(BuildContext context) {
    final funding = widget.detail.fundingInfo;
    final seller = widget.detail.sellerInfo;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 🔹 대표 이미지
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: CachedNetworkImage(
              imageUrl: funding.imageUrls.isNotEmpty
                  ? funding.imageUrls.first
                  : 'https://via.placeholder.com/300x200?text=No+Image',
              height: 220,
              width: double.infinity,
              fit: BoxFit.cover,
              placeholder: (_, __) =>
                  const Center(child: CircularProgressIndicator()),
              errorWidget: (_, __, ___) => const Center(
                child: Icon(Icons.broken_image, size: 48, color: Colors.grey),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // 🔹 제목 + D-Day
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(funding.title, style: AppTextStyles.heading3),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _buildRemainingDaysText(funding.endDate),
                  style: AppTextStyles.body2.copyWith(color: AppColors.primary),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // 🔹 설명
          Text(funding.description, style: AppTextStyles.body1),
          const SizedBox(height: 20),

          // 🔹 펀딩 진행률 + 금액 + 버튼 (리팩토링)
          _buildFundingProgressSection(funding),
          const Divider(height: 32),

          // 🔹 판매자
          Text("판매자", style: AppTextStyles.caption),
          const SizedBox(height: 4),
          Text(
            seller.sellerName,
            style: AppTextStyles.body1.copyWith(fontWeight: FontWeight.bold),
          ),
          const Divider(height: 32),

          // 🔹 가격 및 수량
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("가격: ${_formatCurrency(funding.price)}원",
                  style: AppTextStyles.body1),
              Text("남은 수량: ${funding.quantity}", style: AppTextStyles.body1),
            ],
          ),
          const Divider(height: 32),

          // 🔹 상세 설명
          Text("상세 설명", style: AppTextStyles.heading3),
          const SizedBox(height: 12),
          _buildStorySection(funding.storyFileUrl),
        ],
      ),
    );
  }

  Widget _buildFundingProgressSection(funding) {
    final dDay = funding.endDate.difference(DateTime.now()).inDays;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 🔸 진행률 + 남은 시간
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Text(
                "${funding.rate.toStringAsFixed(1)}%",
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              "남은시간: ${dDay > 0 ? "$dDay일 남음" : "마감"}",
              style: AppTextStyles.body1.copyWith(color: Colors.grey[800]),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // 🔸 진행률 바
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: LinearProgressIndicator(
            value: funding.rate / 100,
            backgroundColor: Colors.grey[200],
            color: AppColors.primary,
            minHeight: 10,
          ),
        ),
        const SizedBox(height: 24),

        // 🔸 펀딩 금액 + 버튼
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // 금액
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("펀딩 금액",
                    style: AppTextStyles.caption.copyWith(fontSize: 18)),
                const SizedBox(height: 4),
                Text(
                  "${_formatCurrency(funding.price)}원",
                  style: AppTextStyles.heading3.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),

            // 펀딩하기 버튼
            ElevatedButton(
              onPressed: () {
                // TODO: 펀딩 로직
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 4,
                shadowColor: AppColors.primary.withOpacity(0.3),
              ),
              child: const Text(
                '펀딩하기',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStorySection(String storyFileUrl) {
    final lowerUrl = storyFileUrl.toLowerCase();

    if (lowerUrl.endsWith('.jpg') ||
        lowerUrl.endsWith('.jpeg') ||
        lowerUrl.endsWith('.png')) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              storyFileUrl,
              height: _showFullStory ? null : 300,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (_, error, __) {
                debugPrint('❌ 이미지 로딩 실패: $error');
                return const Center(child: Text('이미지를 불러올 수 없습니다.'));
              },
              loadingBuilder: (_, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return const SizedBox(
                  height: 300,
                  child: Center(child: CircularProgressIndicator()),
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {
                setState(() {
                  _showFullStory = !_showFullStory;
                });
              },
              child: Text(
                _showFullStory ? '닫기' : '더 보기',
                style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          )
        ],
      );
    } else {
      return const Text(
        '이미지 형식이 아니거나 지원되지 않는 파일입니다.',
        style: TextStyle(color: Colors.redAccent),
      );
    }
  }

  String _buildRemainingDaysText(DateTime endDate) {
    final today = DateTime.now();
    final diff = endDate.difference(today).inDays;
    if (diff > 0) {
      return "D-$diff";
    } else if (diff == 0) {
      return "D-Day";
    } else {
      return "종료됨";
    }
  }

  String _formatCurrency(int amount) {
    return amount.toString().replaceAllMapped(
        RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (match) => '${match[1]},');
  }
}
