import 'dart:async'; // Import Timer
import 'package:flutter/material.dart';
import 'package:front/core/themes/app_colors.dart'; // Assuming AppColors exists
import 'package:front/core/themes/app_text_styles.dart'; // Import AppTextStyles
import 'package:intl/intl.dart'; // For number formatting

import '../../data/models/funding_model.dart';

// Convert to StatefulWidget
class FundingCard extends StatefulWidget {
  final FundingModel funding;
  const FundingCard({super.key, required this.funding});

  @override
  State<FundingCard> createState() => _FundingCardState();
}

class _FundingCardState extends State<FundingCard> {
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
    return NumberFormat('#,###원').format(amount);
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
    final progress =
        (widget.funding.currentAmount / widget.funding.targetAmount)
            .clamp(0.0, 1.0);

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
          ClipRRect(
            borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16)), // Match container radius
            child: Image.network(
              widget.funding.imageUrls.isNotEmpty
                  ? widget.funding.imageUrls.first
                  : 'https://via.placeholder.com/340x180', // Placeholder 이미지 높이 조정
              width: double.infinity,
              height: 180, // 카드 세로 크기 증가를 위해 이미지 높이 증가
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: double.infinity,
                  height: 180, // 에러 시 높이도 일치
                  color: AppColors.lightGrey
                      .withOpacity(0.3), // Match ProjectCard placeholder color
                  child: const Center(
                    child:
                        Icon(Icons.image_not_supported, color: AppColors.grey),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8), // 제목과 설명 사이 간격 조정

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
                  value: progress,
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
                            '${(progress * 100).toStringAsFixed(0)}%', // Use integer percentage
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
