import 'package:flutter/material.dart';
import 'package:front/features/mypage/ui/widgets/suport_content_page.dart';

class FaqScreen extends StatelessWidget {
  const FaqScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const SupportContentPage(
      title: '자주 묻는 질문',
      paragraphs: [
        'Q1. 펀딩은 어떻게 참여하나요?\nA. 펀딩 리스트에서 원하는 상품을 선택 후 결제를 진행하면 됩니다.',
        'Q2. 후원금은 언제 결제되나요?\nA. 목표금액 도달 시점에 결제됩니다.',
      ],
    );
  }
}
