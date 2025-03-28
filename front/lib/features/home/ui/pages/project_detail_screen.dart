import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:front/core/themes/app_colors.dart';
import 'package:front/core/themes/app_text_styles.dart';
import 'package:front/core/themes/app_shadows.dart';
import 'package:front/features/home/domain/entities/project_entity.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ProjectDetailScreen extends ConsumerWidget {
  final int projectId;
  final ProjectEntity? project;

  const ProjectDetailScreen({
    super.key,
    required this.projectId,
    this.project,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 프로젝트가 전달되지 않았을 경우 로딩 상태 표시 또는 데이터 로드 로직 추가 필요
    final screenSize = MediaQuery.of(context).size;

    if (project == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('프로젝트 상세'),
          backgroundColor: AppColors.white,
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverAppBar(
              expandedHeight: screenSize.height * 0.4,
              floating: false,
              pinned: true,
              backgroundColor: AppColors.white,
              elevation: 0,
              leading: IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.white.withOpacity(0.8),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        spreadRadius: 0,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.arrow_back,
                    color: AppColors.darkGrey,
                    size: 20,
                  ),
                ),
                onPressed: () => context.pop(),
              ),
              actions: [
                Padding(
                  padding: const EdgeInsets.only(right: 16.0),
                  child: IconButton(
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.white.withOpacity(0.8),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            spreadRadius: 0,
                          ),
                        ],
                      ),
                      child: Icon(
                        project!.isLiked
                            ? Icons.favorite
                            : Icons.favorite_border,
                        color:
                            project!.isLiked ? Colors.red : AppColors.darkGrey,
                        size: 20,
                      ),
                    ),
                    onPressed: () {
                      // 찜하기 로직
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('찜하기가 토글되었습니다.'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                  ),
                ),
              ],
              flexibleSpace: FlexibleSpaceBar(
                background: Stack(
                  children: [
                    Positioned.fill(
                      child: CachedNetworkImage(
                        imageUrl: project!.imageUrl,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          color: AppColors.lightGrey.withOpacity(0.3),
                          child: const Center(
                            child: CircularProgressIndicator(),
                          ),
                        ),
                        errorWidget: (context, url, error) => Container(
                          color: AppColors.lightGrey.withOpacity(0.3),
                          child: const Center(
                            child: Icon(
                              Icons.error_outline,
                              color: AppColors.grey,
                              size: 50,
                            ),
                          ),
                        ),
                      ),
                    ),
                    // 그래디언트 오버레이
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withOpacity(0.4),
                            ],
                            stops: const [0.7, 1.0],
                          ),
                        ),
                      ),
                    ),
                    // 제목
                    Positioned(
                      bottom: 20,
                      left: 20,
                      right: 20,
                      child: Text(
                        project!.title,
                        style: AppTextStyles.heading3.copyWith(
                          color: Colors.white,
                          shadows: [
                            Shadow(
                              blurRadius: 8.0,
                              color: Colors.black.withOpacity(0.5),
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  color: AppColors.white,
                  boxShadow: [AppShadows.card],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withOpacity(0.2),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Text(
                            '${project!.percentage.toStringAsFixed(1)}%',
                            style: const TextStyle(
                              color: AppColors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          '남은시간: ${project!.remainingTime}',
                          style: AppTextStyles.body2.copyWith(
                            color: AppColors.darkGrey,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // 프로그레스 바
                    Container(
                      height: 8,
                      decoration: BoxDecoration(
                        color: AppColors.lightGrey.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final width = constraints.maxWidth *
                              (project!.percentage / 100);
                          return Row(
                            children: [
                              Container(
                                width: width,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      AppColors.primary,
                                      Color(0xFF8BC34A),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(4),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.primary.withOpacity(0.3),
                                      blurRadius: 4,
                                      offset: const Offset(0, 1),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 20),
                    // 펀딩 금액 및 버튼
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '펀딩 금액',
                              style: AppTextStyles.caption.copyWith(
                                color: AppColors.grey,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              project!.price,
                              style: AppTextStyles.heading3.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        ElevatedButton(
                          onPressed: () {
                            // 펀딩하기 로직
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('펀딩하기 버튼이 클릭되었습니다.'),
                                duration: Duration(seconds: 2),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 16,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 2,
                          ),
                          child: const Text(
                            '펀딩하기',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  color: AppColors.white,
                  boxShadow: [AppShadows.card],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 4,
                          height: 20,
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.all(Radius.circular(4)),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '프로젝트 소개',
                          style: AppTextStyles.heading3.copyWith(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      project!.description,
                      style: AppTextStyles.body1,
                    ),
                    const SizedBox(height: 30),
                    Row(
                      children: [
                        Container(
                          width: 4,
                          height: 20,
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.all(Radius.circular(4)),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '상세 설명',
                          style: AppTextStyles.heading3.copyWith(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '이 프로젝트는 ${project!.title}로, 혁신적인 아이디어와 기술을 통해 사용자들에게 새로운 가치를 제공합니다. 저희 팀은 열정과 전문성을 바탕으로 이 프로젝트를 성공적으로 완수하기 위해 최선을 다하고 있습니다.\n\n여러분의 지원과 관심이 이 프로젝트의 성공에 큰 힘이 됩니다. 함께해 주셔서 감사합니다!',
                      style: AppTextStyles.body1,
                    ),
                    // 추가 정보
                    const SizedBox(height: 30),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.primary.withOpacity(0.1),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '펀딩 참여 혜택',
                            style: AppTextStyles.body1.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          _buildBenefitItem('프로젝트 완성품을 가장 먼저 받아보실 수 있습니다.'),
                          _buildBenefitItem('제작 과정에 참여할 수 있는 기회가 주어집니다.'),
                          _buildBenefitItem('참여자 이름이 프로젝트 공식 웹사이트에 기재됩니다.'),
                          _buildBenefitItem('프로젝트 관련 이벤트에 우선 초대됩니다.'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBenefitItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.check_circle,
            size: 18,
            color: AppColors.primary,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: AppTextStyles.body2,
            ),
          ),
        ],
      ),
    );
  }
}
