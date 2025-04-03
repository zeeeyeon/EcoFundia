import 'package:flutter/material.dart';
import 'package:front/utils/logger_util.dart';
import 'package:flutter/foundation.dart' show kDebugMode;

/// 페이지네이션 Mixin
///
/// 페이지네이션을 지원하는 ViewModel에서 사용할 수 있는 Mixin으로
/// 페이지네이션 로직을 통일하고 중복 코드를 줄입니다.
mixin PaginationMixin on ChangeNotifier {
  // 현재 페이지
  int _currentPage = 0;
  int get currentPage => _currentPage;

  // 페이지당 항목 수
  int _pageSize = 20;
  int get pageSize => _pageSize;
  set pageSize(int value) {
    if (value > 0 && _pageSize != value) {
      _pageSize = value;
      notifyListeners();
    }
  }

  // 마지막 페이지 여부
  bool _isLastPage = false;
  bool get isLastPage => _isLastPage;

  // 추가 데이터 로딩 중 여부
  bool _isLoadingMore = false;
  bool get isLoadingMore => _isLoadingMore;

  // 총 항목 수 (서버가 제공하는 경우)
  int? _totalItems;
  int? get totalItems => _totalItems;

  /// 페이지네이션 상태 초기화
  void resetPagination() {
    _currentPage = 0;
    _isLastPage = false;
    _isLoadingMore = false;
    _totalItems = null;
  }

  /// 다음 페이지 로딩 시작
  bool startLoadingMore() {
    // 이미 로딩 중이거나 마지막 페이지인 경우 로딩하지 않음
    if (_isLoadingMore || _isLastPage) {
      if (kDebugMode) {
        LoggerUtil.d('페이지네이션: 이미 로딩 중이거나 마지막 페이지입니다. 로딩 취소');
      }
      return false;
    }

    _isLoadingMore = true;
    notifyListeners();
    return true;
  }

  /// 페이지네이션 성공 처리
  void onPaginationSuccess({required int itemCount, int? totalItems}) {
    _isLoadingMore = false;

    // 다음 페이지로 이동
    _currentPage++;

    // 총 항목 수가 제공된 경우 저장
    if (totalItems != null) {
      _totalItems = totalItems;
    }

    // 가져온 항목 수가 페이지 크기보다 작으면 마지막 페이지로 판단
    if (itemCount < _pageSize) {
      _isLastPage = true;
      if (kDebugMode) {
        LoggerUtil.d(
            '페이지네이션: 마지막 페이지 도달 (항목 수: $itemCount < 페이지 크기: $_pageSize)');
      }
    }

    notifyListeners();
  }

  /// 페이지네이션 실패 처리
  void onPaginationError() {
    _isLoadingMore = false;
    notifyListeners();
  }

  /// 다음 페이지 로드 가능 여부 확인
  bool canLoadMore() {
    return !_isLoadingMore && !_isLastPage;
  }

  /// 특정 페이지로 이동 (주로 검색 필터 변경 등에 사용)
  void goToPage(int page) {
    if (page >= 0 && page != _currentPage) {
      _currentPage = page;
      _isLastPage = false;
      notifyListeners();
    }
  }

  /// 페이지 번호를 0부터 시작하는 인덱스로 변환 (API에 따라 사용)
  int getPageIndex() {
    return _currentPage;
  }

  /// 페이지 번호를 1부터 시작하는 번호로 변환 (API에 따라 사용)
  int getPageNumber() {
    return _currentPage + 1;
  }
}
