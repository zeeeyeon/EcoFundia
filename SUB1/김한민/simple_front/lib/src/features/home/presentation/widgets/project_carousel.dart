import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/auth_utils.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'project_card.dart';

class ProjectCarousel extends ConsumerStatefulWidget {
  final List<Map<String, dynamic>> projects;

  const ProjectCarousel({
    super.key,
    required this.projects,
  });

  @override
  ConsumerState<ProjectCarousel> createState() => _ProjectCarouselState();
}

class _ProjectCarouselState extends ConsumerState<ProjectCarousel>
    with SingleTickerProviderStateMixin {
  final PageController _pageController = PageController();
  late final AnimationController _fireAnimationController;
  Timer? _timer;
  int _currentPage = 0;
  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();
    _fireAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    // 초기화 후 타이머 시작
    _startAutoScroll();
  }

  @override
  void dispose() {
    _isDisposed = true;
    if (_timer != null) {
      _timer!.cancel();
      _timer = null;
    }
    _pageController.dispose();
    _fireAnimationController.dispose();
    super.dispose();
  }

  void _startAutoScroll() {
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      // 위젯이 dispose 되었는지 확인
      if (_isDisposed) {
        timer.cancel();
        return;
      }

      if (!mounted) {
        timer.cancel();
        return;
      }

      if (_currentPage < widget.projects.length - 1) {
        _currentPage++;
      } else {
        _currentPage = 0;
      }

      if (_pageController.hasClients) {
        _pageController.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final carouselHeight = screenSize.height * 0.6; // 전체 화면의 60%

    return LayoutBuilder(
      builder: (context, constraints) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: constraints.maxWidth * 0.05,
              ),
              child: Row(
                children: [
                  Text(
                    AppStrings.topProject,
                    style: AppTextStyles.topProjectTitle.copyWith(
                      fontSize: screenSize.width * 0.06,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  AnimatedBuilder(
                    animation: _fireAnimationController,
                    builder: (context, child) {
                      return Transform.translate(
                        offset: Offset(0, 2 * _fireAnimationController.value),
                        child: ShaderMask(
                          shaderCallback: (bounds) => LinearGradient(
                            colors: const [
                              Color(0xFFFF0000), // 빨간색 (불꽃 중심)
                              Color(0xFFFF4500), // 밝은 주황색
                              Color(0xFFFFD700), // 황금색 (불꽃 끝)
                            ],
                            stops: [
                              0.0,
                              0.5,
                              1.0 - _fireAnimationController.value * 0.3,
                            ],
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                          ).createShader(bounds),
                          child: Text(
                            ' 🔥',
                            style: TextStyle(
                              fontSize: screenSize.width * 0.06,
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
            const SizedBox(height: 16),
            SizedBox(
              height: carouselHeight,
              child: PageView.builder(
                controller: _pageController,
                itemCount: widget.projects.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemBuilder: (context, index) {
                  final project = widget.projects[index];
                  return Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: constraints.maxWidth * 0.025,
                    ),
                    child: ProjectCard(
                      title: project['title'],
                      description: project['description'],
                      imageUrl: project['imageUrl'],
                      percentage: project['percentage'],
                      price: project['price'],
                      remainingTime: project['remainingTime'],
                      onPurchaseTap: () {
                        if (AuthUtils.checkAuthAndShowModal(
                            context, ref, 'purchase')) {
                          // TODO: 구매 로직 구현
                        }
                      },
                      onLikeTap: () {
                        if (AuthUtils.checkAuthAndShowModal(
                            context, ref, 'like')) {
                          // TODO: 좋아요 로직 구현
                        }
                      },
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: screenSize.height * 0.02),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                widget.projects.length,
                (index) => Container(
                  width: screenSize.width * 0.02,
                  height: screenSize.width * 0.02,
                  margin: EdgeInsets.symmetric(
                    horizontal: screenSize.width * 0.01,
                  ),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _currentPage == index
                        ? Colors.black
                        : Colors.grey.withOpacity(0.3),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
