import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';
import 'dart:math';

final totalFundProvider =
    StateNotifierProvider<TotalFundNotifier, String>((ref) {
  return TotalFundNotifier();
});

class TotalFundNotifier extends StateNotifier<String> {
  Timer? _timer;
  int _currentIndex = 0;
  final Random _random = Random();

  final List<String> _amounts = [
    '252,324,122원',
    '298,156,430원',
    '315,789,650원',
    '342,567,890원',
    '378,912,345원',
    '401,234,567원',
    '445,678,912원',
    '489,123,456원',
    '512,345,678원',
    '567,890,123원',
    '589,012,345원',
    '612,345,678원',
    '645,678,901원',
    '678,901,234원',
    '701,234,567원',
    '734,567,890원',
    '767,890,123원',
    '789,012,345원',
    '812,345,678원',
    '845,678,901원',
  ];

  TotalFundNotifier() : super('252,324,122원') {
    _startRotation();
  }

  void _startRotation() {
    _timer?.cancel();
    // 개발 중에는 5초마다 업데이트하고, 나중에 배포 시 20초로 변경할 수 있습니다
    _timer = Timer.periodic(const Duration(seconds: 20), (_) {
      // 순차적 업데이트 대신 랜덤한 금액 선택 (테스트용)
      int nextIndex;
      do {
        nextIndex = _random.nextInt(_amounts.length);
      } while (nextIndex == _currentIndex); // 같은 금액이 연속으로 선택되지 않도록

      _currentIndex = nextIndex;
      state = _amounts[_currentIndex];
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

final topProjectsProvider =
    FutureProvider<List<Map<String, dynamic>>>((ref) async {
  // TODO: API 연동 시 실제 데이터로 교체
  // 임시 데이터 반환
  await Future.delayed(const Duration(seconds: 1)); // API 호출 시뮬레이션

  return [
    {
      'title': 'Super Banana',
      'description': '슈퍼 바나나 입니다.',
      'imageUrl':
          'https://images.unsplash.com/photo-1571771894821-ce9b6c11b08e',
      'percentage': 73.0,
      'price': '995,000원',
      'remainingTime': '1h 23m 32s',
    },
    {
      'title': 'Smart Watch',
      'description': '최신 스마트 워치입니다.',
      'imageUrl': 'https://images.unsplash.com/photo-1546868871-7041f2a55e12',
      'percentage': 45.0,
      'price': '1,200,000원',
      'remainingTime': '3h 45m 12s',
    },
    {
      'title': 'Eco Bag',
      'description': '환경 친화적인 에코백입니다.',
      'imageUrl':
          'https://images.unsplash.com/photo-1591534577302-3824b8d0b1d8',
      'percentage': 89.0,
      'price': '35,000원',
      'remainingTime': '2h 10m 5s',
    },
    {
      'title': 'Coffee Maker',
      'description': '프리미엄 커피 메이커입니다.',
      'imageUrl':
          'https://images.unsplash.com/photo-1517668808822-9ebb02f2a0e6',
      'percentage': 62.0,
      'price': '450,000원',
      'remainingTime': '5h 30m 45s',
    },
    {
      'title': 'Wireless Earbuds',
      'description': '고음질 무선 이어버드입니다.',
      'imageUrl':
          'https://images.unsplash.com/photo-1606220588913-b3aacb4d2f46',
      'percentage': 55.0,
      'price': '180,000원',
      'remainingTime': '8h 15m 30s',
    },
  ];
});
