import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CustomerSupportSection extends StatelessWidget {
  const CustomerSupportSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 섹션 타이틀
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 20, 16, 8),
          child: Text(
            "고객지원",
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),

        const Divider(height: 1, thickness: 1, color: Colors.grey),

        _buildSupportItem(context, title: "1:1 문의", route: '/support/inquiry'),
        _buildSupportItem(context, title: "자주 물어보는 Q&A", route: '/support/faq'),
        _buildSupportItem(context, title: "공지사항", route: '/support/notice'),
        _buildSupportItem(context, title: "앱 사용 가이드", route: '/support/guide'),
        _buildSupportItem(context,
            title: "이용약관 / 개인정보 처리방침", route: '/support/policy'),

        // 구분선
        const Divider(height: 1, thickness: 1, color: Colors.grey),

        // 고객센터 정보
        _buildInfoItem("고객센터", "000-0000"),
        _buildInfoItem("버전 정보", "v1.0.0"),
      ],
    );
  }

  // 클릭 가능한 항목
  Widget _buildSupportItem(BuildContext context,
      {required String title, required String route}) {
    return InkWell(
      onTap: () => context.push(route),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, thickness: 1, color: Colors.grey),
        ],
      ),
    );
  }

  // 단순 정보 표시용
  Widget _buildInfoItem(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 15,
              color: Colors.black54,
            ),
          ),
        ],
      ),
    );
  }
}
