import 'package:flutter/material.dart';
import 'package:front/core/constants/app_strings.dart';
import 'package:front/core/themes/app_colors.dart';
import 'package:front/core/themes/app_text_styles.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:front/features/home/domain/entities/project_entity.dart';
import 'project_card.dart';
import 'package:carousel_slider/carousel_slider.dart';

/// 프로젝트 캐러셀 위젯
class ProjectCarousel extends ConsumerStatefulWidget {
  final List<ProjectEntity> projects;
  final Function(ProjectEntity) onPurchaseTap;
  final Function(ProjectEntity) onLikeTap;

  const ProjectCarousel({
    super.key,
    required this.projects,
    required this.onPurchaseTap,
    required this.onLikeTap,
  });

  @override
  ConsumerState<ProjectCarousel> createState() => _ProjectCarouselState();
}

class _ProjectCarouselState extends ConsumerState<ProjectCarousel>
    with SingleTickerProviderStateMixin {
  late final AnimationController _fireAnimationController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();

    // 불꽃 애니메이션 초기화
    _fireAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _fireAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 360;
    final scaleFactor = isSmallScreen ? 0.85 : 1.0;

    // 카드와 동일한 크기로 캐러셀 높이 설정
    final double carouselHeight = 460 * scaleFactor;

    // 반응형 UI 요소 계산
    final horizontalPadding = 20.0 * scaleFactor;
    final titleFontSize = isSmallScreen ? 20.0 : 24.0;
    final dotSize = 5.0 * scaleFactor;
    final dotSpacing = 3.0 * scaleFactor;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // "TOP PROJECT" 제목 영역
        Padding(
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
          child: Row(
            children: [
              Text(
                AppStrings.topProject,
                style: AppTextStyles.heading2.copyWith(
                  fontSize: titleFontSize,
                  fontWeight: FontWeight.bold,
                ),
              ),
              // 불꽃 애니메이션 아이콘
              AnimatedBuilder(
                animation: _fireAnimationController,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(0, 2 * _fireAnimationController.value),
                    child: ShaderMask(
                      shaderCallback: (bounds) => const LinearGradient(
                        colors: [
                          Color(0xFFFF0000),
                          Color(0xFFFF4500),
                          Color(0xFFFFD700),
                        ],
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                      ).createShader(bounds),
                      child: Text(
                        ' 🔥',
                        style: TextStyle(
                          fontSize: titleFontSize,
                          height: 1,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),

        // 프로젝트 캐러셀
        SizedBox(
          height: carouselHeight,
          child: widget.projects.isEmpty
              ? _buildEmptyState(scaleFactor)
              : _buildCarousel(carouselHeight, dotSize, dotSpacing),
        ),
      ],
    );
  }

  /// 프로젝트가 없을 때 표시할 빈 상태 위젯
  Widget _buildEmptyState(double scaleFactor) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.info_outline,
            size: 48 * scaleFactor,
            color: Colors.grey[400],
          ),
          SizedBox(height: 16 * scaleFactor),
          Text(
            '프로젝트 데이터가 없습니다',
            style: AppTextStyles.body1.copyWith(
              fontSize: 16 * scaleFactor,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  /// 프로젝트 캐러셀 위젯
  Widget _buildCarousel(
      double carouselHeight, double dotSize, double dotSpacing) {
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        CarouselSlider.builder(
          itemCount: widget.projects.length,
          itemBuilder: (context, index, realIndex) {
            if (index >= widget.projects.length) {
              return const SizedBox();
            }
            final project = widget.projects[index];
            return ProjectCard(
              project: project,
              onPurchaseTap: () => widget.onPurchaseTap(project),
              onLikeTap: widget.onLikeTap,
            );
          },
          options: CarouselOptions(
            height: carouselHeight,
            aspectRatio: 4 / 5,
            viewportFraction: 0.85,
            enlargeCenterPage: true,
            enlargeFactor: 0.2,
            enableInfiniteScroll: widget.projects.length > 1,
            autoPlay: widget.projects.length > 1,
            autoPlayInterval: const Duration(seconds: 3),
            autoPlayAnimationDuration: const Duration(milliseconds: 800),
            autoPlayCurve: Curves.fastOutSlowIn,
            onPageChanged: (index, reason) {
              setState(() => _currentPage = index);
            },
          ),
        ),

        // 하단 도트 인디케이터 (프로젝트가 2개 이상일 때만 표시)
        if (widget.projects.length > 1)
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                widget.projects.length,
                (index) => Container(
                  width: dotSize,
                  height: dotSize,
                  margin: EdgeInsets.symmetric(horizontal: dotSpacing),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _currentPage == index
                        ? AppColors.primary
                        : Colors.grey.withOpacity(0.5),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
