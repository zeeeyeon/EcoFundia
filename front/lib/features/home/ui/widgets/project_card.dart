import 'dart:async';
import 'package:flutter/material.dart';
import 'package:front/core/constants/app_strings.dart';
import 'package:front/core/themes/app_colors.dart';
import 'package:front/core/themes/app_text_styles.dart';
import 'package:front/features/home/domain/entities/project_entity.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';

/// 프로젝트 카드 위젯
class ProjectCard extends StatefulWidget {
  final ProjectEntity project;
  final VoidCallback onPurchaseTap;
  final VoidCallback onLikeTap;

  const ProjectCard({
    super.key,
    required this.project,
    required this.onPurchaseTap,
    required this.onLikeTap,
  });

  @override
  State<ProjectCard> createState() => _ProjectCardState();
}

class _ProjectCardState extends State<ProjectCard> {
  late Timer _timer;
  String _remainingTime = '';

  @override
  void initState() {
    super.initState();
    // 초기 남은 시간 계산
    _calculateRemainingTime();
    // 1초마다 남은 시간 업데이트
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      _calculateRemainingTime();
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _calculateRemainingTime() {
    final now = DateTime.now();
    final endDate = widget.project.endDate;

    if (endDate.isBefore(now)) {
      setState(() {
        _remainingTime = '마감됨';
      });
      return;
    }

    final duration = endDate.difference(now);
    final days = duration.inDays;
    final hours = duration.inHours.remainder(24);
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    setState(() {
      if (days > 0) {
        _remainingTime =
            '$days일 ${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')} 남음';
      } else {
        _remainingTime =
            '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')} 남음';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenSize = MediaQuery.of(context).size;
        final isSmallScreen = screenSize.width < 360;

        // 기본 카드 크기 설정
        const double baseCardHeight = 460;
        const double baseImageRatio = 0.55;
        final scaleFactor = isSmallScreen ? 0.85 : 1.0;

        final cardWidth = constraints.maxWidth;
        final cardHeight = baseCardHeight * scaleFactor;
        final imageHeight = cardHeight * baseImageRatio;

        // 글꼴 크기 계산
        final titleSize = 18.0 * scaleFactor;
        final descSize = 14.0 * scaleFactor;
        final priceSize = 18.0 * scaleFactor;

        return GestureDetector(
          onTap: () {
            context.push('/project/${widget.project.id}',
                extra: {'project': widget.project});
          },
          child: Container(
            width: cardWidth,
            height: cardHeight,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: AppColors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 프로젝트 이미지
                ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(16)),
                  child: SizedBox(
                    height: imageHeight,
                    child: CachedNetworkImage(
                      imageUrl: widget.project.imageUrl,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: AppColors.lightGrey.withOpacity(0.3),
                        child: const Center(
                          child: CircularProgressIndicator(),
                        ),
                      ),
                      errorWidget: (context, error, stackTrace) => Container(
                        color: AppColors.lightGrey.withOpacity(0.3),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.image_not_supported,
                                  size: 28 * scaleFactor,
                                  color: AppColors.grey),
                              SizedBox(height: 4 * scaleFactor),
                              Text(
                                '이미지를 불러올 수 없습니다',
                                style: AppTextStyles.caption.copyWith(
                                  color: AppColors.grey,
                                  fontSize: 11 * scaleFactor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 10 * scaleFactor),

                // 프로젝트 정보
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16 * scaleFactor,
                    vertical: 6 * scaleFactor,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // 프로젝트 제목
                      Text(
                        widget.project.title,
                        style: AppTextStyles.heading3.copyWith(
                          fontSize: titleSize,
                          fontWeight: FontWeight.w700,
                          height: 1.0,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 8 * scaleFactor),

                      // 프로젝트 설명
                      Text(
                        widget.project.description,
                        style: AppTextStyles.body2.copyWith(
                          fontSize: descSize,
                          color: AppColors.grey,
                          height: 1.1,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),

                // 공간 확보
                const Spacer(),

                // 하단 정보 및 버튼
                Padding(
                  padding: EdgeInsets.only(
                    left: 16 * scaleFactor,
                    right: 16 * scaleFactor,
                    bottom: 12 * scaleFactor,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // 왼쪽 정보 (퍼센트, 가격, 남은 시간)
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              children: [
                                // 퍼센트
                                Text(
                                  '${widget.project.percentage.toStringAsFixed(1)}%',
                                  style: AppTextStyles.heading3.copyWith(
                                    fontSize: priceSize,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primary,
                                    height: 1.0,
                                  ),
                                ),
                                SizedBox(width: 8 * scaleFactor),

                                // 가격
                                Expanded(
                                  child: Text(
                                    widget.project.price,
                                    style: AppTextStyles.heading3.copyWith(
                                      fontSize: priceSize * 0.95,
                                      height: 1.0,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 5 * scaleFactor),

                            // 남은 시간
                            Text(
                              _remainingTime,
                              style: AppTextStyles.body2.copyWith(
                                fontSize: descSize * 0.9,
                                color: AppColors.grey,
                                height: 1.0,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // 버튼 그룹
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          //좋아요버튼튼
                          InkWell(
                            onTap: widget.onLikeTap,
                            child: Icon(
                              widget.project.isLiked
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color: widget.project.isLiked
                                  ? AppColors.primary
                                  : AppColors.grey,
                              size: 24 * scaleFactor,
                            ),
                          ),
                          SizedBox(width: 8 * scaleFactor),
                          ElevatedButton(
                            onPressed: widget.onPurchaseTap,
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.symmetric(
                                horizontal: 16 * scaleFactor,
                                vertical: 8 * scaleFactor,
                              ),
                              backgroundColor: AppColors.primary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Text(
                              AppStrings.purchase,
                              style: AppTextStyles.body1.copyWith(
                                fontSize: descSize,
                                color: AppColors.white,
                                fontWeight: FontWeight.w600,
                              ),
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
        );
      },
    );
  }
}
