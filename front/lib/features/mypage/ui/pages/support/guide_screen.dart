import 'package:flutter/material.dart';
import 'package:front/features/mypage/ui/widgets/suport_content_page.dart';

class GuideScreen extends StatelessWidget {
  const GuideScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const SupportContentPage(title: '앱 사용 가이드', paragraphs: [
      '1. 홈 화면에서 다양한 펀딩 프로젝트를 탐색해보세요.',
      '2. 상세 페이지에서 스토리, 이미지, 목표 금액 등의 정보를 확인할 수 있어요.',
      '3. 마음에 드는 프로젝트는 하트를 눌러 찜할 수 있어요.',
      '4. 펀딩에 참여하고, 응원 메시지도 함께 남겨보세요.',
      '5. 참여한 프로젝트에는 후기를 남겨 경험을 공유해보세요.',
      '6. 오늘의 인기 펀딩을 확인하고, 트렌드를 빠르게 파악해보세요.',
    ]);
  }
}
