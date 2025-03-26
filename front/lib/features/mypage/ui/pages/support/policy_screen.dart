import 'package:flutter/material.dart';
import 'package:front/features/mypage/ui/widgets/suport_content_page.dart';

class PolicyScreen extends StatelessWidget {
  const PolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const SupportContentPage(
      title: '이용약관 / 개인정보 처리방침',
      paragraphs: [
        '■ 이용약관\n- 본 앱은 펀딩 중개 서비스입니다.',
        '■ 개인정보 처리방침\n- 사용자의 정보는 안전하게 암호화되어 저장됩니다.',
      ],
    );
  }
}
