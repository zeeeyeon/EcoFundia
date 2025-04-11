import 'package:flutter/material.dart';
import 'package:front/features/mypage/ui/widgets/suport_content_page.dart';

class NoticeScreen extends StatelessWidget {
  const NoticeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const SupportContentPage(
      title: '공지사항',
      paragraphs: [
        '[2025-03-25] 서버 점검 안내\n- 점검 일시: 3/27 02:00 ~ 04:00',
        '[2025-03-20] 앱 업데이트 안내\n- UI/UX 개선 및 버그 수정',
      ],
    );
  }
}
