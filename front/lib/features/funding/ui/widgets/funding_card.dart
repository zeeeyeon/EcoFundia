import 'dart:async'; // Import Timer
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Riverpod import 추가
import 'package:front/core/themes/app_colors.dart'; // Assuming AppColors exists
import 'package:front/core/themes/app_text_styles.dart'; // Import AppTextStyles
import 'package:intl/intl.dart'; // For number formatting
import 'package:cached_network_image/cached_network_image.dart'; // 패키지 import 추가

import '../../data/models/funding_model.dart';
import 'package:front/features/wishlist/ui/view_model/wishlist_provider.dart'; // wishlistIdsProvider import
import 'package:front/features/wishlist/ui/view_model/wishlist_view_model.dart';
import 'package:front/utils/auth_utils.dart';
import 'package:front/utils/logger_util.dart';

// ConsumerWidget으로 변경
class FundingCard extends ConsumerStatefulWidget {
  // ConsumerStatefulWidget으로 변경하여 타이머 유지
  final FundingModel funding;
  const FundingCard({super.key, required this.funding});

  @override
  ConsumerState<FundingCard> createState() =>
      _FundingCardState(); // ConsumerState 반환
}

// ConsumerState로 변경
class _FundingCardState extends ConsumerState<FundingCard> {
  Timer? _timer;
  String _remainingTimeString = "";
  bool _isEnded = false;

  @override
  void initState() {
    super.initState();
    _remainingTimeString = _calculateRemainingTime();
    if (!_isEnded) {
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        _updateRemainingTime();
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _updateRemainingTime() {
    final newTime = _calculateRemainingTime();
    if (mounted && newTime != _remainingTimeString) {
      setState(() {
        _remainingTimeString = newTime;
      });
    }
    if (_isEnded && _timer?.isActive == true) {
      _timer?.cancel();
    }
  }

  // Helper to format currency
  String _formatCurrency(int amount) {
    return NumberFormat('#,##0원').format(amount);
  }

  // Updated remaining time calculation
  String _calculateRemainingTime() {
    final now = DateTime.now();
    final endDate = widget.funding.endDate ?? now.add(const Duration(days: 0));
    final difference = endDate.difference(now);

    if (difference.isNegative) {
      _isEnded = true;
      return "종료됨";
    }
    _isEnded = false;

    final days = difference.inDays;
    final hours = difference.inHours % 24;
    final minutes = difference.inMinutes % 60;
    final seconds = difference.inSeconds % 60;

    String timeString = "";
    if (days > 0) {
      timeString = "$days일 ";
    }

    timeString +=
        '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';

    return timeString;
  }

  @override
  Widget build(BuildContext context) {
    // 찜 상태 확인
    final wishlistIds = ref.watch(wishlistIdsProvider);
    final isLiked = wishlistIds.contains(widget.funding.fundingId);

    // 실제 진행률 계산
    final actualProgressRatio =
        widget.funding.currentAmount <= 0 || widget.funding.targetAmount <= 0
            ? 0.0
            : widget.funding.currentAmount / widget.funding.targetAmount;
    // 프로그레스 바에 표시될 값 (0.0 ~ 1.0)
    final displayProgress = actualProgressRatio.clamp(0.0, 1.0);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16), // Match ProjectCard radius
        color: AppColors.white,
        border: Border.all(
          // Add subtle border
          color: AppColors.lightGrey.withOpacity(0.5),
          width: 0.5,
        ),
        boxShadow: [
          // Match ProjectCard shadow
          BoxShadow(
            color: Colors.grey.withOpacity(0.15), // Slightly darker shadow
            blurRadius: 15, // Slightly less blur
            spreadRadius: 1, // Slightly spread
            offset: const Offset(0, 6), // Shadow lower
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Stack으로 이미지와 아이콘 감싸기
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16)), // Match container radius
                child: CachedNetworkImage(
                  imageUrl: widget.funding.imageUrls.isNotEmpty
                      ? widget.funding.imageUrls.first
                      : 'https://via.placeholder.com/340x180', // 기본 이미지 URL
                  placeholder: (context, url) => Container(
                    // 로딩 중 플레이스홀더
                    width: double.infinity,
                    height: 180,
                    color: AppColors.lightGrey.withOpacity(0.3),
                    child: const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                        strokeWidth: 2.0,
                      ),
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    // 에러 위젯
                    width: double.infinity,
                    height: 180, // 에러 시 높이도 일치
                    color: AppColors.lightGrey.withOpacity(0.3),
                    child: const Center(
                      child: Icon(Icons.image_not_supported,
                          color: AppColors.grey),
                    ),
                  ),
                  width: double.infinity,
                  height: 180, // 카드 세로 크기 증가를 위해 이미지 높이 증가
                  fit: BoxFit.cover,
                ),
              ),
              // 찜 아이콘 (Positioned 사용)
              Positioned(
                top: 8, // 상단 여백
                right: 8, // 우측 여백
                child: InkWell(
                  onTap: () async {
                    LoggerUtil.d(
                        '❤️ FundingCard 찜하기 버튼 클릭: ${widget.funding.fundingId}');
                    // 로그인 확인
                    final isAuthorized = await AuthUtils.checkAuthAndShowModal(
                      context,
                      ref,
                    );
                    if (!isAuthorized) return; // 로그인 안됐으면 종료

                    // WishlistViewModel의 toggleWishlistItem 호출
                    await ref
                        .read(wishlistViewModelProvider.notifier)
                        .toggleWishlistItem(
                          widget.funding.fundingId,
                          context: context,
                          ref: ref,
                        );
                  },
                  borderRadius: BorderRadius.circular(20), // InkWell 효과 범위
                  child: Container(
                    padding: const EdgeInsets.all(4), // 아이콘 주변 여백
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.3), // 반투명 배경
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isLiked ? Icons.favorite : Icons.favorite_border,
                      color: isLiked ? AppColors.primary : Colors.white,
                      size: 20, // 아이콘 크기
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8), // 이미지와 내용 사이 간격

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.funding.title,
                  style: AppTextStyles.heading3.copyWith(
                    fontSize:
                        18, // Keep size consistent or apply scaleFactor if needed
                    fontWeight: FontWeight.w700,
                    height: 1.0,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8), // 제목과 설명 사이 간격 조정

                Text(
                  widget.funding.description,
                  style: AppTextStyles.body2.copyWith(
                    fontSize: 14,
                    color: AppColors.darkGrey, // 좀 더 진한 회색
                    height: 1.2, // 줄 간격 약간 조정
                  ),
                  maxLines: 2, // Allow 2 lines like ProjectCard
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 16), // 설명과 구분선 사이 간격 증가

                LinearProgressIndicator(
                  value: displayProgress, // 프로그레스 바에는 제한된 값 사용
                  backgroundColor: AppColors.extraLightGrey,
                  color: AppColors.primary,
                  minHeight: 12, // 진행률 막대 높이 증가
                  borderRadius: BorderRadius.circular(4),
                ),
                const SizedBox(height: 12), // 진행률과 하단 정보 사이 간격 증가

                Padding(
                  padding: const EdgeInsets.only(bottom: 12), // 하단 패딩 증가
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // 왼쪽: 펀딩률 + 현재 금액
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            '${(actualProgressRatio * 100).toStringAsFixed(0)}%', // 텍스트에는 실제 진행률 사용
                            style: AppTextStyles.heading3.copyWith(
                              fontSize: 20, // 펀딩률 크기 약간 키움
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _formatCurrency(widget.funding.currentAmount),
                            style: AppTextStyles.body1.copyWith(
                              fontSize: 14, // 현재 금액 폰트 크기 줄임
                              color: AppColors.textDark,
                              fontWeight: FontWeight.w500,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                      // 오른쪽: 남은 시간
                      Row(
                        children: [
                          const Icon(
                            Icons.access_time_filled,
                            size: 14,
                            color: AppColors.grey,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _remainingTimeString,
                            style: AppTextStyles.body2.copyWith(
                              fontSize: 13, // 이미지와 유사하게 크기 조정
                              color: AppColors.grey,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
