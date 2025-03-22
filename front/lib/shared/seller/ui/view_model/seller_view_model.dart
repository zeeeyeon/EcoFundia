import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:front/shared/seller/domain/entities/seller_entity.dart';
import 'package:front/shared/seller/domain/entities/review_entity.dart';
import 'package:front/shared/seller/domain/entities/seller_project_entity.dart';
import 'package:front/shared/seller/domain/usecases/get_seller_details_usecase.dart';
import 'package:front/shared/seller/domain/usecases/get_seller_projects_usecase.dart';
import 'package:front/shared/seller/domain/usecases/get_seller_reviews_usecase.dart';
import 'package:front/shared/seller/domain/repositories/seller_repository.dart';

/// 판매자 정보 상태
enum SellerLoadingState {
  initial,
  loading,
  loaded,
  error,
}

/// 판매자 탭 구분
enum SellerTab {
  active,
  ended,
}

/// 판매자 정보 ViewModel
class SellerViewModel extends ChangeNotifier {
  final GetSellerDetailsUseCase _getSellerDetailsUseCase;
  final GetSellerProjectsUseCase _getSellerProjectsUseCase;
  final GetSellerReviewsUseCase _getSellerReviewsUseCase;

  SellerViewModel({
    required GetSellerDetailsUseCase getSellerDetailsUseCase,
    required GetSellerProjectsUseCase getSellerProjectsUseCase,
    required GetSellerReviewsUseCase getSellerReviewsUseCase,
  })  : _getSellerDetailsUseCase = getSellerDetailsUseCase,
        _getSellerProjectsUseCase = getSellerProjectsUseCase,
        _getSellerReviewsUseCase = getSellerReviewsUseCase;

  // 판매자 정보 상태
  SellerLoadingState _sellerState = SellerLoadingState.initial;
  SellerLoadingState get sellerState => _sellerState;

  // 프로젝트 목록 상태 (진행 중)
  SellerLoadingState _activeProjectsState = SellerLoadingState.initial;
  SellerLoadingState get activeProjectsState => _activeProjectsState;

  // 프로젝트 목록 상태 (종료)
  SellerLoadingState _endedProjectsState = SellerLoadingState.initial;
  SellerLoadingState get endedProjectsState => _endedProjectsState;

  // 리뷰 목록 상태
  SellerLoadingState _reviewsState = SellerLoadingState.initial;
  SellerLoadingState get reviewsState => _reviewsState;

  // 현재 선택된 탭
  SellerTab _currentTab = SellerTab.active;
  SellerTab get currentTab => _currentTab;

  // 판매자 정보
  SellerEntity? _seller;
  SellerEntity? get seller => _seller;

  // 진행 중인 프로젝트 목록
  List<SellerProjectEntity> _activeProjects = [];
  List<SellerProjectEntity> get activeProjects => _activeProjects;

  // 종료된 프로젝트 목록
  List<SellerProjectEntity> _endedProjects = [];
  List<SellerProjectEntity> get endedProjects => _endedProjects;

  // 리뷰 목록
  List<ReviewEntity> _reviews = [];
  List<ReviewEntity> get reviews => _reviews;

  // 에러 메시지
  String _errorMessage = '';
  String get errorMessage => _errorMessage;

  /// 탭 변경 처리
  void changeTab(SellerTab tab) {
    _currentTab = tab;
    notifyListeners();
  }

  /// 판매자 정보 및 프로젝트, 리뷰 로드
  Future<void> loadSellerInfo(int sellerId) async {
    await _loadSellerDetails(sellerId);
    await _loadActiveProjects(sellerId);
    await _loadEndedProjects(sellerId);
    await _loadReviews(sellerId);
  }

  /// 판매자 상세 정보 로드
  Future<void> _loadSellerDetails(int sellerId) async {
    _sellerState = SellerLoadingState.loading;
    notifyListeners();

    try {
      _seller = await _getSellerDetailsUseCase.execute(sellerId);
      _sellerState = SellerLoadingState.loaded;
    } catch (e) {
      _sellerState = SellerLoadingState.error;
      _errorMessage = '판매자 정보를 불러오는데 실패했습니다: $e';
    }

    notifyListeners();
  }

  /// 진행 중인 프로젝트 목록 로드
  Future<void> _loadActiveProjects(int sellerId) async {
    _activeProjectsState = SellerLoadingState.loading;
    notifyListeners();

    try {
      _activeProjects =
          await _getSellerProjectsUseCase.getActiveProjects(sellerId);
      _activeProjectsState = SellerLoadingState.loaded;
    } catch (e) {
      _activeProjectsState = SellerLoadingState.error;
      _errorMessage = '진행 중인 프로젝트를 불러오는데 실패했습니다: $e';
    }

    notifyListeners();
  }

  /// 종료된 프로젝트 목록 로드
  Future<void> _loadEndedProjects(int sellerId) async {
    _endedProjectsState = SellerLoadingState.loading;
    notifyListeners();

    try {
      _endedProjects =
          await _getSellerProjectsUseCase.getEndedProjects(sellerId);
      _endedProjectsState = SellerLoadingState.loaded;
    } catch (e) {
      _endedProjectsState = SellerLoadingState.error;
      _errorMessage = '종료된 프로젝트를 불러오는데 실패했습니다: $e';
    }

    notifyListeners();
  }

  /// 리뷰 목록 로드
  Future<void> _loadReviews(int sellerId) async {
    _reviewsState = SellerLoadingState.loading;
    notifyListeners();

    try {
      _reviews = await _getSellerReviewsUseCase.execute(sellerId);
      _reviewsState = SellerLoadingState.loaded;
    } catch (e) {
      _reviewsState = SellerLoadingState.error;
      _errorMessage = '리뷰를 불러오는데 실패했습니다: $e';
    }

    notifyListeners();
  }

  /// 프로젝트 새로고침
  Future<void> refreshProjects(int sellerId) async {
    if (currentTab == SellerTab.active) {
      await _loadActiveProjects(sellerId);
    } else {
      await _loadEndedProjects(sellerId);
    }
  }

  /// 평균 별점 계산
  double getAverageRating() {
    if (_reviews.isEmpty) {
      return 0.0;
    }

    double total = _reviews.fold(0.0, (sum, review) => sum + review.rating);
    return total / _reviews.length;
  }
}

/// 판매자 정보 ViewModel Provider
final sellerViewModelProvider = ChangeNotifierProvider<SellerViewModel>((ref) {
  final getSellerDetailsUseCase = ref.watch(getSellerDetailsUseCaseProvider);
  final getSellerProjectsUseCase = ref.watch(getSellerProjectsUseCaseProvider);
  final getSellerReviewsUseCase = ref.watch(getSellerReviewsUseCaseProvider);

  return SellerViewModel(
    getSellerDetailsUseCase: getSellerDetailsUseCase,
    getSellerProjectsUseCase: getSellerProjectsUseCase,
    getSellerReviewsUseCase: getSellerReviewsUseCase,
  );
});

/// GetSellerDetailsUseCase Provider
final getSellerDetailsUseCaseProvider =
    Provider<GetSellerDetailsUseCase>((ref) {
  final repository = ref.watch(sellerRepositoryProvider);
  return GetSellerDetailsUseCase(repository);
});

/// GetSellerProjectsUseCase Provider
final getSellerProjectsUseCaseProvider =
    Provider<GetSellerProjectsUseCase>((ref) {
  final repository = ref.watch(sellerRepositoryProvider);
  return GetSellerProjectsUseCase(repository);
});

/// GetSellerReviewsUseCase Provider
final getSellerReviewsUseCaseProvider =
    Provider<GetSellerReviewsUseCase>((ref) {
  final repository = ref.watch(sellerRepositoryProvider);
  return GetSellerReviewsUseCase(repository);
});

/// SellerRepository Provider
final sellerRepositoryProvider = Provider<SellerRepository>((ref) {
  // 실제 구현체는 SellerRepositoryImpl을 사용하나,
  // 여기서는 모듈간 의존성을 위해 아직 주입하지 않음
  // 앱 모듈에서 override를 통해 실제 구현체 주입 필요
  throw UnimplementedError('sellerRepositoryProvider was not overridden');
});
