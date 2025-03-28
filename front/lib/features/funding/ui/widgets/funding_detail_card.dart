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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 🔹 대표 이미지
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: CachedNetworkImage(
              imageUrl: funding.imageUrls.isNotEmpty
                  ? funding.imageUrls.first
                  : 'https://via.placeholder.com/300x200?text=No+Image',
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
              placeholder: (_, __) =>
                  const Center(child: CircularProgressIndicator()),
              errorWidget: (_, __, ___) => const Center(
                child: Icon(Icons.broken_image, size: 48, color: Colors.grey),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // 🔹 제목
          Text(funding.title, style: AppTextStyles.heading3),
          const SizedBox(height: 8),

          // 🔹 설명
          Text(funding.description, style: AppTextStyles.body1),
          const SizedBox(height: 16),

          // 🔹 펀딩 진행률
          LinearProgressIndicator(
            value: funding.rate / 100,
            backgroundColor: Colors.grey[300],
            color: AppColors.primary,
            minHeight: 10,
          ),
          const SizedBox(height: 8),
          Text("달성률: ${funding.rate}%", style: AppTextStyles.body2),
          const SizedBox(height: 16),

          // 🔹 판매자 정보
          Row(
            children: [
              CircleAvatar(
                backgroundImage: NetworkImage(seller.sellerProfileImageUrl),
                onBackgroundImageError: (_, __) {
                  debugPrint('❌ 판매자 이미지 로딩 실패');
                },
              ),
              const SizedBox(width: 12),
              Text(
                seller.sellerName,
                style:
                    AppTextStyles.body1.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 🔹 가격 및 수량
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("가격: ${funding.price}원", style: AppTextStyles.body1),
              Text("남은 수량: ${funding.quantity}", style: AppTextStyles.body1),
            ],
          ),
          const SizedBox(height: 16),

          // 🔹 기간
          Text(
            "진행기간: ${_formatDate(funding.startDate)} ~ ${_formatDate(funding.endDate)}",
            style: AppTextStyles.caption,
          ),
          const SizedBox(height: 24),

          // 🔹 상세 설명
          Text("상세 설명", style: AppTextStyles.heading3),
          const SizedBox(height: 8),
          _buildStorySection(funding.storyFileUrl),
        ],
      ),
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
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              storyFileUrl,
              height: _showFullStory ? null : 300,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                debugPrint('❌ 이미지 로딩 실패: $error');
                return const Center(child: Text('이미지를 불러올 수 없습니다.'));
              },
              loadingBuilder: (context, child, loadingProgress) {
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

  String _formatDate(DateTime date) {
    return "${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')}";
  }
}
