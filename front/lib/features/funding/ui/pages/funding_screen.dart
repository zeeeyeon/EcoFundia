import 'package:flutter/material.dart';
import 'package:front/core/ui/widgets/loading_overlay.dart';

class FundingScreen extends StatelessWidget {
  const FundingScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 로딩 상태는 추후 상태 관리 구현 시 추가
    const isLoading = false;

    return LoadingOverlay(
      isLoading: isLoading,
      message: '펀딩 정보를 불러오는 중...',
      child: Scaffold(
        appBar: AppBar(
          title: const Text('펀딩'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                '펀딩 화면',
                style: TextStyle(fontSize: 24),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  // 펀딩 상세 페이지로 이동
                },
                child: const Text('펀딩 참여하기'),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  // 펀딩 목록 페이지로 이동
                },
                child: const Text('모든 펀딩 보기'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
