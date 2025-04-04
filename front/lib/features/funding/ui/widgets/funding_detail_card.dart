import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
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
    final screenSize = MediaQuery.of(context).size;

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: screenSize.height * 0.4,
          pinned: true,
          backgroundColor: Colors.white,
          flexibleSpace: FlexibleSpaceBar(
            background: CachedNetworkImage(
              imageUrl:
                  funding.imageUrls.isNotEmpty ? funding.imageUrls.first : '',
              fit: BoxFit.cover,
              placeholder: (_, __) =>
                  const Center(child: CircularProgressIndicator()),
              errorWidget: (_, __, ___) => const Center(
                child: Icon(Icons.broken_image, size: 48, color: Colors.grey),
              ),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTitleAndDday(funding),
                const SizedBox(height: 12),
                Text(funding.description, style: AppTextStyles.body2),
                const SizedBox(height: 20),
                _buildFundingProgressSection(funding),
                const SizedBox(height: 10),
                _buildSellerSection(seller),
                const SizedBox(height: 16),
                _buildChatButton(funding.fundingId, funding.title),
                const Divider(height: 32),
                Text("상세 설명",
                    style: AppTextStyles.caption.copyWith(fontSize: 18)),
                const SizedBox(height: 12),
                _buildStorySection(funding.storyFileUrl),
              ],
            ),
          ),
        )
      ],
    );
  }

  Widget _buildTitleAndDday(FundingInfo funding) {
    final diff = funding.endDate.difference(DateTime.now()).inDays;
    final dDayText = diff < 0 ? "마감" : (diff == 0 ? "D-Day" : "D-$diff");

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(funding.title, style: AppTextStyles.heading3),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            dDayText,
            style: AppTextStyles.body2.copyWith(color: AppColors.primary),
          ),
        ),
      ],
    );
  }

  Widget _buildFundingProgressSection(FundingInfo funding) {
    final dDay = funding.endDate.difference(DateTime.now()).inDays;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(30),
              ),
              child: Text(
                funding.rate % 1 == 0
                    ? "${funding.rate.toInt()}%"
                    : "${funding.rate.toStringAsFixed(1)}%",
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              dDay < 0 ? "마감" : "남은시간: $dDay일 남음",
              style: AppTextStyles.body2.copyWith(color: Colors.grey[800]),
            ),
          ],
        ),
        const SizedBox(height: 12),
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

        // 💰 금액 + 펀딩하기 버튼
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
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
            ElevatedButton(
              onPressed: () {
                // TODO: 펀딩하기 동작
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text(
                '펀딩하기',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),
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
          AnimatedCrossFade(
            firstChild: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                storyFileUrl,
                width: double.infinity,
                height: 300,
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
            secondChild: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                storyFileUrl,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            crossFadeState: _showFullStory
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 300),
          ),
          const SizedBox(height: 12),
          Center(
            child: OutlinedButton.icon(
              onPressed: () {
                setState(() {
                  _showFullStory = !_showFullStory;
                });
              },
              icon: Icon(
                _showFullStory ? Icons.expand_less : Icons.expand_more,
                size: 18,
                color: Colors.black87,
              ),
              label: Text(
                _showFullStory ? '접기' : '상품 정보 더보기',
                style: const TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.w500,
                ),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.black87),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              ),
            ),
          ),
        ],
      );
    } else {
      return const Text(
        '이미지 형식이 아니거나 지원되지 않는 파일입니다.',
        style: TextStyle(color: Colors.redAccent),
      );
    }
  }

  Widget _buildSellerSection(SellerInfo seller) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      margin: const EdgeInsets.only(top: 8),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.primary),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("판매자", style: AppTextStyles.caption.copyWith(fontSize: 18)),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  seller.sellerName,
                  style: AppTextStyles.body1.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w800,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  context.push('/seller/${widget.detail.fundingInfo.sellerId}');
                  // sellerId를 경로에 포함
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  "판매자 상세 정보",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChatButton(int fundingId, String fundingTitle) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () {
          context.push(
            '/chat/room/$fundingId',
            extra: {'title': fundingTitle}, // ✅ 여전히 title은 넘김!
          );
        },
        icon: const Icon(Icons.chat_bubble_outline),
        label: const Text(
          '채팅하기',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.primary),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }

  String _formatCurrency(int amount) {
    return amount.toString().replaceAllMapped(
          RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
          (match) => '${match[1]},',
        );
  }
}
