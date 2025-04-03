import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:front/shared/seller/domain/entities/seller_entity.dart';
import 'package:front/shared/seller/domain/entities/review_entity.dart';
import 'package:front/shared/seller/domain/entities/seller_project_entity.dart';
import 'package:front/shared/seller/domain/usecases/get_seller_details_usecase.dart';
import 'package:front/shared/seller/domain/usecases/get_seller_projects_usecase.dart';
import 'package:front/shared/seller/domain/usecases/get_seller_reviews_usecase.dart';
import 'package:front/shared/seller/domain/repositories/seller_repository.dart';
import 'package:front/shared/seller/data/repositories/seller_repository_impl.dart';
import 'package:front/utils/logger_util.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// 판매자 정보 상태
enum SellerLoadingState {
  initial,
  loading,
  loaded,
  error,
  networkError, // 네트워크 오류 상태 추가
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

  // 로딩 중인 작업 추적
  int _loadingTaskCount = 0;
  bool get isLoading => _loadingTaskCount > 0;

  // 네트워크 오류 확인 (재시도 버튼 표시 여부)
  bool _isNetworkError = false;
  bool get isNetworkError => _isNetworkError;

  // 오류 코드
  int? _lastErrorCode;
  int? get lastErrorCode => _lastErrorCode;

  /// 에러 상태 설정 (오류 종류에 따라 다른 UI 제공)
  void _setErrorState(SellerLoadingState state, dynamic error) {
    _lastErrorCode = null;

    if (error is SellerException) {
      _lastErrorCode = error.statusCode;

      if (error.isNetwork) {
        // 네트워크 오류인 경우 네트워크 오류 상태로 설정
        _isNetworkError = true;
        _errorMessage = _getNetworkErrorMessage(error);
        state = SellerLoadingState.networkError;
      } else {
        // 일반 오류
        _isNetworkError = false;
        _errorMessage = error.message;
        state = SellerLoadingState.error;
      }
    } else if (error is DioException) {
      // Dio 오류 직접 처리
      _isNetworkError = true;
      _lastErrorCode = error.response?.statusCode;
      _errorMessage = _getDioErrorMessage(error);
      state = SellerLoadingState.networkError;
    } else {
      // 일반 오류
      _isNetworkError = false;
      _errorMessage = '데이터를 불러오는데 실패했습니다. 다시 시도해 주세요.';
      state = SellerLoadingState.error;
    }

    if (kDebugMode) {
      LoggerUtil.e(
          '오류 상태 설정: $state, 메시지: $_errorMessage, 코드: $_lastErrorCode');
    }
  }

  /// Dio 오류에 대한 사용자 친화적인 메시지 생성
  String _getDioErrorMessage(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return '서버 응답이 너무 늦습니다. 인터넷 연결을 확인하고 다시 시도해 주세요.';
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        if (statusCode == 404) {
          return '요청한 정보를 찾을 수 없습니다. 잠시 후 다시 시도해 주세요.';
        } else if (statusCode == 500) {
          return '서버에 문제가 발생했습니다. 잠시 후 다시 시도해 주세요.';
        } else if (statusCode == 503) {
          return '서비스가 일시적으로 사용 불가능합니다. 잠시 후 다시 시도해 주세요.';
        }
        return '서버 응답 오류 (${error.response?.statusCode}). 다시 시도해 주세요.';
      case DioExceptionType.cancel:
        return '요청이 취소되었습니다. 다시 시도해 주세요.';
      case DioExceptionType.connectionError:
        return '네트워크 연결에 문제가 있습니다. 인터넷 연결을 확인하고 다시 시도해 주세요.';
      case DioExceptionType.unknown:
      default:
        return '알 수 없는 오류가 발생했습니다. 인터넷 연결을 확인하고 다시 시도해 주세요.';
    }
  }

  /// 네트워크 오류에 대한 사용자 친화적인 메시지 생성
  String _getNetworkErrorMessage(SellerException error) {
    final statusCode = error.statusCode;

    if (statusCode == null) {
      return '네트워크 연결에 문제가 있습니다. 인터넷 연결을 확인하고 다시 시도해 주세요.';
    }

    // 상태 코드별 맞춤 메시지
    switch (statusCode) {
      case 0: // 연결 실패
        return '서버에 연결할 수 없습니다. 인터넷 연결을 확인하고 다시 시도해 주세요.';
      case 404:
        return '요청한 정보를 찾을 수 없습니다. 잠시 후 다시 시도해 주세요.';
      case 408: // 요청 시간 초과
        return '서버 응답 시간이 초과되었습니다. 인터넷 연결을 확인하고 다시 시도해 주세요.';
      case 500:
        return '서버에 문제가 발생했습니다. 잠시 후 다시 시도해 주세요.';
      case 502: // Bad Gateway
      case 503: // Service Unavailable
      case 504: // Gateway Timeout
        return '서비스가 일시적으로 사용 불가능합니다. 잠시 후 다시 시도해 주세요.';
      default:
        return error.message;
    }
  }

  /// 판매자 정보 및 프로젝트, 리뷰 로드
  Future<void> loadSellerInfo(int sellerId) async {
    if (kDebugMode) {
      LoggerUtil.i('판매자 정보 로드 시작: ID $sellerId');
    }

    // 모든 상태 초기화
    _clearError();

    // 판매자 정보와 리뷰 로드를 병렬로 실행 (API 명세 변경으로 프로젝트 목록은 판매자 정보와 함께 받아옴)
    await Future.wait([
      _loadSellerDetailsWithProjects(sellerId),
      // 새로 화면에 진입했을 때는 리뷰도 함께 로드
      _loadReviews(sellerId),
    ], eagerError: false); // eagerError: false로 설정하여 일부 실패해도 계속 진행

    if (kDebugMode) {
      LoggerUtil.i('판매자 정보 로드 완료: ID $sellerId');
    }
  }

  /// 로딩 상태 추적 시작
  void _startLoading() {
    _loadingTaskCount++;
    if (_loadingTaskCount == 1) {
      notifyListeners(); // 첫 번째 작업이 시작될 때만 알림
    }
  }

  /// 로딩 상태 추적 종료
  void _finishLoading() {
    _loadingTaskCount--;
    if (_loadingTaskCount == 0) {
      notifyListeners(); // 마지막 작업이 완료될 때만 알림
    }
  }

  /// 판매자 상세 정보와 프로젝트 목록 함께 로드 (API 개선)
  Future<void> _loadSellerDetailsWithProjects(int sellerId) async {
    if (_sellerState == SellerLoadingState.loading) {
      return; // 이미 로딩 중이면 중복 방지
    }

    _sellerState = SellerLoadingState.loading;
    _activeProjectsState = SellerLoadingState.loading;
    _endedProjectsState = SellerLoadingState.loading;
    _startLoading();
    notifyListeners();

    try {
      if (kDebugMode) {
        LoggerUtil.d('판매자 정보 및 프로젝트 로드 시작: $sellerId');
      }

      // 판매자 상세 정보 로드 (프로젝트 목록 포함)
      _seller = await _getSellerDetailsUseCase.execute(sellerId);
      _sellerState = SellerLoadingState.loaded;

      if (kDebugMode) {
        LoggerUtil.d('판매자 정보 로드 성공: ${_seller?.name}');
      }

      // 판매자 정보와 함께 받아온 프로젝트 목록 조회
      await _loadProjectsFromRepository(sellerId);
    } catch (e) {
      if (kDebugMode) {
        LoggerUtil.e('판매자 정보 및 프로젝트 로드 실패', e);
      }
      _seller = null; // 오류 발생 시 이전 데이터 제거
      _activeProjects = [];
      _endedProjects = [];

      // 상태 업데이트
      _setErrorState(_sellerState, e);
      _activeProjectsState = _sellerState; // 판매자 정보 상태와 동일하게 설정
      _endedProjectsState = _sellerState; // 판매자 정보 상태와 동일하게 설정
    } finally {
      _finishLoading();
      notifyListeners();
    }
  }

  /// 리포지토리에서 프로젝트 목록 조회 (캐시 데이터 활용)
  Future<void> _loadProjectsFromRepository(int sellerId) async {
    try {
      // 진행 중인 프로젝트 로드
      _activeProjects =
          await _getSellerProjectsUseCase.getActiveProjects(sellerId);
      _activeProjectsState = SellerLoadingState.loaded;

      if (kDebugMode) {
        LoggerUtil.d('진행 중인 프로젝트 로드 성공: ${_activeProjects.length}개');
      }

      // 종료된 프로젝트 로드
      _endedProjects =
          await _getSellerProjectsUseCase.getEndedProjects(sellerId);
      _endedProjectsState = SellerLoadingState.loaded;

      if (kDebugMode) {
        LoggerUtil.d('종료된 프로젝트 로드 성공: ${_endedProjects.length}개');
      }
    } catch (e) {
      if (kDebugMode) {
        LoggerUtil.e('프로젝트 목록 로드 실패', e);
      }
      _activeProjects = [];
      _endedProjects = [];
      _activeProjectsState = SellerLoadingState.error;
      _endedProjectsState = SellerLoadingState.error;
      rethrow; // 상위 호출자에게 예외 전파
    }
  }

  /// 리뷰 목록 로드
  Future<void> _loadReviews(int sellerId) async {
    if (_reviewsState == SellerLoadingState.loading) {
      return; // 이미 로딩 중이면 중복 방지
    }

    _reviewsState = SellerLoadingState.loading;
    _startLoading();
    notifyListeners();

    try {
      if (kDebugMode) {
        LoggerUtil.d('리뷰 목록 로드 시작: $sellerId');
      }
      _reviews = await _getSellerReviewsUseCase.execute(sellerId);
      _reviewsState = SellerLoadingState.loaded;
      if (kDebugMode) {
        LoggerUtil.d('리뷰 로드 성공: ${_reviews.length}개');
      }
    } catch (e) {
      if (kDebugMode) {
        LoggerUtil.e('리뷰 로드 실패', e);
      }
      _reviews = []; // 오류 발생 시 이전 데이터 제거
      _setErrorState(_reviewsState, e);
    } finally {
      _finishLoading();
      notifyListeners();
    }
  }

  /// 프로젝트 새로고침
  Future<void> refreshProjects(int sellerId) async {
    // 현재 API 개선으로 프로젝트 목록은 판매자 정보와 함께 받아옴
    // 따라서 판매자 정보를 다시 로드하여 프로젝트 목록도 함께 업데이트
    if (kDebugMode) {
      LoggerUtil.i('프로젝트 데이터 새로 로드 시작: $sellerId');
    }
    await _loadSellerDetailsWithProjects(sellerId);
  }

  /// 모든 데이터 새로고침
  Future<void> refreshAllData(int sellerId) async {
    if (kDebugMode) {
      LoggerUtil.i('판매자 정보 전체 새로고침 시작: ID $sellerId');
    }
    await loadSellerInfo(sellerId);
  }

  /// 리뷰 데이터만 로드 (탭 변경 시 사용)
  Future<void> loadReviews(int sellerId) async {
    // 이미 로드된 리뷰 데이터가 있고 정상 상태인 경우 중복 호출 방지
    if (_reviewsState == SellerLoadingState.loaded && _reviews.isNotEmpty) {
      if (kDebugMode) {
        LoggerUtil.d('이미 로드된 리뷰 데이터 사용 (${_reviews.length}개)');
      }
      return;
    }

    if (kDebugMode) {
      LoggerUtil.i('판매자 리뷰만 별도 로드 시작: ID $sellerId');
    }
    await _loadReviews(sellerId);
  }

  /// 에러 메시지 초기화
  void clearError() {
    _errorMessage = '';
    _isNetworkError = false;
    _lastErrorCode = null;
    notifyListeners();
  }

  /// 모든 상태 및 에러 초기화
  void _clearError() {
    _errorMessage = '';
    _isNetworkError = false;
    _lastErrorCode = null;
  }

  /// 평균 별점 계산
  double getAverageRating() {
    if (_reviews.isEmpty) {
      return 0.0;
    }

    double total = _reviews.fold(0.0, (sum, review) => sum + review.rating);
    return double.parse(
        (total / _reviews.length).toStringAsFixed(1)); // 소수점 첫째 자리까지 표시
  }

  /// 리소스 정리
  @override
  void dispose() {
    if (kDebugMode) {
      LoggerUtil.d('SellerViewModel 리소스 정리');
    }
    super.dispose();
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
