import 'package:flutter/material.dart';
import '../../data/models/profile_model.dart';

class GreetingMessage extends StatelessWidget {
  final ProfileModel profile;

  const GreetingMessage({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
      child: Align(
        alignment: Alignment.centerLeft, // ✅ 왼쪽 정렬 적용
        child: RichText(
          textAlign: TextAlign.left, // ✅ 텍스트 내부도 왼쪽 정렬
          text: TextSpan(
            style: const TextStyle(fontSize: 18, color: Colors.black),
            children: [
              TextSpan(
                text: profile.username,
                style: const TextStyle(
                    fontWeight: FontWeight.bold, color: Colors.black),
              ),
              const TextSpan(
                text: "님, 반가워요! 친환경 프로젝트를 함께 만들어가요! ",
              ),
              const WidgetSpan(
                child: Icon(Icons.spa, color: Colors.green, size: 20), // 🌱 아이콘
              ),
            ],
          ),
        ),
      ),
    );
  }
}
