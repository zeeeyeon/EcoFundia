import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:front/core/constants/app_strings.dart';
import 'package:front/core/themes/app_colors.dart';
import 'package:front/core/themes/app_text_styles.dart';
import 'package:front/features/home/domain/entities/project_entity.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:front/utils/auth_utils.dart';
import 'package:front/core/providers/app_state_provider.dart';
import 'package:front/utils/logger_util.dart';

/// 프로젝트 카드 위젯
class ProjectCard extends ConsumerStatefulWidget {
  final ProjectEntity project;
  final VoidCallback onPurchaseTap;
  final Function(ProjectEntity) onLikeTap;

  const ProjectCard({
    super.key,
    required this.project,
    required this.onPurchaseTap,
    required this.onLikeTap,
  });

  @override
  ConsumerState<ProjectCard> createState() => _ProjectCardState();
}

class _ProjectCardState extends ConsumerState<ProjectCard> {
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

  // 좋아요 버튼 클릭 핸들러
  void _handleLikeTap() async {
    // 먼저 동기 Provider를 통해 로그인 상태 확인 (즉각적인 상태 확인)
    final isLoggedIn = ref.read(isLoggedInProvider);

    if (!isLoggedIn) {
      LoggerUtil.d('👍 좋아요 시도: 로그인 상태 확인 - 로그인 필요 (동기 상태 체크)');

      // 로그인이 필요한 경우 모달 표시
      final isAuthenticated = await AuthUtils.checkAuthAndShowModal(
        context,
        ref,
      );

      if (!isAuthenticated) {
        LoggerUtil.d('👍 좋아요 토글: ${widget.project.id}, 인증: 필요 → 인증 모달 표시됨');
        return; // 로그인하지 않으면 좋아요 기능 실행하지 않고 종료
      }
    }

    // 인증된 경우에만 실제 좋아요 로직 실행
    LoggerUtil.d('👍 좋아요 토글: ${widget.project.id}, 인증: 성공 → 좋아요 작업 실행');
    widget.onLikeTap(widget.project);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenSize = MediaQuery.of(context).size;
        final isSmallScreen = screenSize.width < 360;

        // 기본 카드 높이 및 비율 조정
        const double baseImageRatio = 0.55; // 이미지 비율 축소
        final scaleFactor = isSmallScreen ? 0.85 : 1.0;

        final cardWidth = constraints.maxWidth;
        final imageHeight = cardWidth * baseImageRatio;

        // 글꼴 크기 계산
        final titleSize = 18.0 * scaleFactor;
        final descSize = 14.0 * scaleFactor;
        final priceSize = 18.0 * scaleFactor;

        return GestureDetector(
          onTap: () {
            context.push('/project/${widget.project.id}');
          },
          child: Container(
            width: cardWidth,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: AppColors.white,
              border: Border.all(
                color: AppColors.lightGrey.withOpacity(0.5),
                width: 0.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.18),
                  blurRadius: 15,
                  spreadRadius: 1,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
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
                SizedBox(height: 18 * scaleFactor), // 이미지와 텍스트 사이 간격 축소

                // 프로젝트 정보
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16 * scaleFactor,
                    vertical: 2 * scaleFactor, // 상하 패딩 축소
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
                      SizedBox(height: 6 * scaleFactor), // 제목과 설명 사이 간격 축소

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

                // 프로젝트 설명과 하단 정보 사이에 간격 축소
                const Spacer(),

                // 하단 정보 및 버튼
                Padding(
                  padding: EdgeInsets.only(
                    left: 16 * scaleFactor,
                    right: 16 * scaleFactor,
                    bottom: 10 * scaleFactor,
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
                            SizedBox(height: 3 * scaleFactor), // 간격 축소

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
                            onTap: _handleLikeTap,
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
