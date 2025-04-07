import 'package:intl/intl.dart';

class DateFormatUtil {
  /// 날짜를 yyyy.MM.dd 형식으로 변환
  static String formatYYYYMMDD(String? dateString) {
    if (dateString == null || dateString.isEmpty) {
      return '-';
    }

    try {
      final date = DateTime.parse(dateString);
      return '${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')}';
    } catch (e) {
      return '-';
    }
  }

  /// 날짜를 yyyy년 MM월 dd일 형식으로 변환
  static String formatYYYYMMDDKorean(String? dateString) {
    if (dateString == null || dateString.isEmpty) {
      return '-';
    }

    try {
      final date = DateTime.parse(dateString);
      return '${date.year}년 ${date.month}월 ${date.day}일';
    } catch (e) {
      return '-';
    }
  }

  /// 날짜를 MM/dd 형식으로 변환
  static String formatMMDD(String? dateString) {
    if (dateString == null || dateString.isEmpty) {
      return '-';
    }

    try {
      final date = DateTime.parse(dateString);
      return '${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}';
    } catch (e) {
      return '-';
    }
  }

  /// 날짜의 남은 일수 계산
  static String getRemainingDays(String? dateString) {
    if (dateString == null || dateString.isEmpty) {
      return '-';
    }

    try {
      final date = DateTime.parse(dateString);
      final now = DateTime.now();
      final remaining = date.difference(now).inDays;

      if (remaining < 0) {
        return '만료됨';
      }

      return '$remaining일 남음';
    } catch (e) {
      return '-';
    }
  }

  /// 금액 형식 변환 (1000 -> 1,000원)
  static String formatCurrency(int amount) {
    return '${NumberFormat.currency(
      locale: 'ko_KR',
      symbol: '',
      decimalDigits: 0,
    ).format(amount)}원';
  }

  /// 날짜의 유효성 체크
  static bool isDateValid(String? dateString) {
    if (dateString == null || dateString.isEmpty) {
      return false;
    }

    try {
      final date = DateTime.parse(dateString);
      final now = DateTime.now();
      return date.isAfter(now);
    } catch (e) {
      return false;
    }
  }
}
