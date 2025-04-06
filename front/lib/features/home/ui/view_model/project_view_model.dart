import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:front/features/home/data/repositories/project_repository_impl.dart';
import 'package:front/features/home/domain/repositories/project_repository.dart';
import 'package:front/features/home/domain/entities/project_entity.dart';
import 'package:logger/logger.dart';
import 'package:front/utils/logger_util.dart';
import 'package:front/features/wishlist/ui/view_model/wishlist_provider.dart';
import 'package:front/core/providers/app_state_provider.dart';

// 프로젝트 상태 정의
class ProjectState {
  final List<ProjectEntity> projects;
  final bool isLoading;
  final String? error;

  ProjectState({
    required this.projects,
    this.isLoading = false,
    this.error,
  });

  ProjectState copyWith({
    List<ProjectEntity>? projects,
    bool? isLoading,
    String? error,
  }) {
    return ProjectState(
      projects: projects ?? this.projects,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

// ViewModel 정의
class ProjectViewModel extends StateNotifier<ProjectState> {
  final ProjectRepository _projectRepository;
  final Logger _logger;
  DateTime? _lastLoadTime; // 마지막 데이터 로드 시간 추적
  Ref? _ref; // Ref 저장 (위시리스트 업데이트를 위해)

  ProjectViewModel(this._projectRepository)
      : _logger = Logger(),
        super(ProjectState(projects: []));

  // 프로젝트 목록이 비어있는지 확인하는 getter
  bool get hasEmptyProjects => state.projects.isEmpty;

  // Ref 설정 (Provider에서 호출)
  void setRef(Ref ref) {
    _ref = ref;
  }

  // 프로젝트 목록 로드
  Future<void> loadProjects() async {
    // 중복 호출 방지 로직 (3초 이내 중복 호출 무시)
    final now = DateTime.now();
    if (_lastLoadTime != null && now.difference(_lastLoadTime!).inSeconds < 3) {
      LoggerUtil.d('🚫 프로젝트 로드 취소: 최근 3초 이내에 이미 요청됨');
      return;
    }
    _lastLoadTime = now;

    try {
      // 이미 로딩 중이면 중복 요청 방지
      if (state.isLoading) {
        LoggerUtil.d('🚫 프로젝트 로드 취소: 이미 로딩 중');
        return;
      }

      // 1. 로딩 상태로 설정 (단, 프로젝트 목록은 아직 업데이트하지 않음)
      LoggerUtil.i('🔄 프로젝트 로드 시작 (로딩 상태 true)');
      state = state.copyWith(isLoading: true, error: null);

      // 2. API에서 프로젝트 데이터 로드 (await로 완료까지 대기)
      LoggerUtil.d('📡 API 호출: 프로젝트 데이터 요청');
      final projects = await _projectRepository.getProjects();
      LoggerUtil.i('✅ 프로젝트 데이터 로드 완료: ${projects.length}개');

      // 3. 위시리스트 ID 가져오기 (현재 저장된 상태)
      Set<int> wishlistIds = <int>{};
      if (_ref != null) {
        // Ref가 있는 경우에만 위시리스트 ID 가져오기
        LoggerUtil.d('🔍 현재 위시리스트 ID 목록 읽기 시작');
        wishlistIds = Set<int>.from(_ref!.read(wishlistIdsProvider));
        LoggerUtil.d(
            '📋 현재 위시리스트 ID 목록: $wishlistIds (${wishlistIds.length}개)');
      } else {
        LoggerUtil.w('⚠️ Ref가 null이라 위시리스트 ID 목록을 가져올 수 없음');
      }

      // 4. 위시리스트 ID와 매칭하여 isLiked 상태가 적용된 최종 Entity 목록 생성
      LoggerUtil.d('🔄 프로젝트와 위시리스트 ID 매칭 시작');
      final updatedProjects = projects.map((project) {
        final fundingId = project.id; // project.id는 fundingId에 해당
        final isLiked = wishlistIds.contains(fundingId);

        // 상태 로깅
        if (isLiked) {
          LoggerUtil.d('💖 프로젝트 ID $fundingId: 위시리스트에 있음 → isLiked=true');
        }

        return project.copyWith(isLiked: isLiked);
      }).toList();

      // 5. 매칭 결과 상세 로깅
      final likedProjectCount = updatedProjects.where((p) => p.isLiked).length;
      final likedProjectIds =
          updatedProjects.where((p) => p.isLiked).map((p) => p.id).toList();

      LoggerUtil.i(
          '✅ 매칭 완료: 전체 ${updatedProjects.length}개 중 $likedProjectCount개 좋아요 (ID: $likedProjectIds)');

      // 각 프로젝트의 상세 isLiked 상태 로깅
      final isLikedStatuses =
          updatedProjects.map((p) => '${p.id}:${p.isLiked}').join(', ');
      LoggerUtil.d('📋 프로젝트 isLiked 최종 상태: [$isLikedStatuses]');

      // 6. 단일 상태 업데이트: 로딩 완료 및 최종 프로젝트 목록 동시 적용
      LoggerUtil.i('🔄 최종 상태 업데이트 직전 (로딩 상태 false, 프로젝트 목록 업데이트)');
      state = state.copyWith(
        projects: updatedProjects, // 위시리스트 ID와 매칭된 상태로 업데이트
        isLoading: false,
      );
      LoggerUtil.i('✅ 최종 상태 업데이트 완료');
    } catch (e) {
      LoggerUtil.e('❌ 프로젝트 로드 실패', e);
      state = state.copyWith(
        isLoading: false,
        error: '프로젝트를 불러오는데 실패했습니다.',
      );
    }
  }

  // 받아온 위시리스트 ID로 프로젝트의 좋아요 상태 업데이트
  void updateProjectsWithWishlistIds(Set<int> wishlistIds) {
    if (state.projects.isEmpty) {
      LoggerUtil.w('⚠️ 프로젝트 목록이 비어있어 위시리스트 ID 매칭을 수행할 수 없음');
      return;
    }

    LoggerUtil.i('🔄 위시리스트 ID로 프로젝트 좋아요 상태 업데이트 시작');
    LoggerUtil.d('📋 적용할 위시리스트 ID 목록: $wishlistIds (${wishlistIds.length}개)');

    // 1. 매칭 전 상태 로깅
    final likedProjectsBefore = state.projects.where((p) => p.isLiked).length;
    final likedProjectIdsBefore =
        state.projects.where((p) => p.isLiked).map((p) => p.id).toList();

    LoggerUtil.d(
        '📊 매칭 전: 전체 ${state.projects.length}개 중 $likedProjectsBefore개 좋아요 (ID: $likedProjectIdsBefore)');

    // 2. 위시리스트 ID와 매칭하여 isLiked 상태가 적용된 최종 Entity 목록 생성
    LoggerUtil.d('🔄 프로젝트와 위시리스트 ID 매칭 시작');
    final updatedProjects = state.projects.map((project) {
      final fundingId = project.id; // project.id는 fundingId에 해당
      final shouldBeLiked = wishlistIds.contains(fundingId);

      // 상태 변경이 필요한 경우 로깅
      if (project.isLiked != shouldBeLiked) {
        if (shouldBeLiked) {
          LoggerUtil.d(
              '➕ 프로젝트 ID $fundingId: 좋아요 상태 변경 ${project.isLiked} → $shouldBeLiked (위시리스트에 추가됨)');
        } else {
          LoggerUtil.d(
              '➖ 프로젝트 ID $fundingId: 좋아요 상태 변경 ${project.isLiked} → $shouldBeLiked (위시리스트에서 제거됨)');
        }
      }

      // 새로운 상태로 프로젝트 복사 (불변성 유지)
      return project.copyWith(isLiked: shouldBeLiked);
    }).toList();

    // 3. 매칭 결과 상세 로깅
    final likedProjectsAfter = updatedProjects.where((p) => p.isLiked).length;
    final likedProjectIdsAfter =
        updatedProjects.where((p) => p.isLiked).map((p) => p.id).toList();

    LoggerUtil.i(
        '✅ 매칭 완료: 전체 ${updatedProjects.length}개 중 $likedProjectsAfter개 좋아요 (ID: $likedProjectIdsAfter)');

    // 변경된 프로젝트가 있는지 확인
    bool hasChanges = false;
    for (int i = 0; i < state.projects.length; i++) {
      if (state.projects[i].isLiked != updatedProjects[i].isLiked) {
        hasChanges = true;
        break;
      }
    }

    // 4. 상태 업데이트 (변경사항이 있는 경우에만)
    if (hasChanges) {
      LoggerUtil.i('🔄 위시리스트 ID 기반으로 프로젝트 좋아요 상태 업데이트 시작');
      // 상태 업데이트 (UI 갱신 트리거)
      state = state.copyWith(projects: updatedProjects);
      LoggerUtil.i('✅ 프로젝트 좋아요 상태 업데이트 완료');
    } else {
      LoggerUtil.d('ℹ️ 위시리스트 ID와 프로젝트 좋아요 상태가 이미 일치함 - 업데이트 건너뜀');
    }
  }

  // 좋아요 토글 (원래 메서드)
  Future<void> toggleLike(ProjectEntity project) async {
    // 원본 프로젝트 목록 백업 (실패 시 롤백을 위함)
    final originalProjects = List<ProjectEntity>.from(state.projects);
    final projectIndex = state.projects.indexWhere((p) => p.id == project.id);

    if (projectIndex == -1) {
      LoggerUtil.w('⚠️ 좋아요 토글: 프로젝트 ID ${project.id}를 찾을 수 없음');
      return;
    }

    final originalIsLiked = project.isLiked;
    // project.id는 fundingId에 해당함
    final fundingId = project.id;

    try {
      LoggerUtil.i(
          '🔄 프로젝트 ID $fundingId 좋아요 토글 시작 ($originalIsLiked → ${!originalIsLiked})');

      // 1. Optimistic UI 업데이트 (즉시 UI 반영)
      final updatedProjects = List<ProjectEntity>.from(state.projects);
      updatedProjects[projectIndex] =
          project.copyWith(isLiked: !originalIsLiked);

      // UI 즉시 업데이트 (API 응답 대기 전)
      LoggerUtil.d('🔄 좋아요 토글: Optimistic UI 업데이트 (API 응답 전)');
      state = state.copyWith(projects: updatedProjects);

      // 2. API 호출 - 토글 요청 (백그라운드로 처리)
      LoggerUtil.d(
          '📡 API 호출: 위시리스트 토글 요청 (프로젝트 ID: $fundingId, 현재 상태: $originalIsLiked)');
      // toggleProjectLike는 fundingId를 파라미터로 받음
      await _projectRepository.toggleProjectLike(fundingId,
          isCurrentlyLiked: originalIsLiked);

      LoggerUtil.i('✅ API 응답 성공: 프로젝트 ID $fundingId 위시리스트 토글 완료');

      // 3. 위시리스트 ID 목록도 동기화 (Ref가 있는 경우)
      if (_ref != null) {
        // 위시리스트 ID 상태 업데이트
        LoggerUtil.d('🔄 위시리스트 ID 상태 동기화 시작');
        _syncWishlistIds(fundingId, !originalIsLiked);
        LoggerUtil.d('✅ 위시리스트 ID 상태 동기화 완료');
      } else {
        LoggerUtil.w('⚠️ Ref가 null이라 위시리스트 ID를 동기화할 수 없음');
      }
    } catch (e) {
      LoggerUtil.e('❌ API 오류: 프로젝트 ID $fundingId 위시리스트 토글 실패', e);

      // 4. 실패 시 UI 롤백 (원래 상태로 되돌림)
      LoggerUtil.d('🔄 API 오류로 인한 UI 롤백');
      state = state.copyWith(
        projects: originalProjects,
        error: '찜 상태 변경에 실패했습니다.',
      );
    }
  }

  // 위시리스트 ID 상태와 동기화
  void _syncWishlistIds(int projectId, bool isLiked) {
    if (_ref == null) {
      LoggerUtil.w('⚠️ 위시리스트 ID 동기화 실패: Ref가 null');
      return;
    }

    try {
      // projectId는 fundingId에 해당
      final fundingId = projectId;

      // 현재 위시리스트 ID Set 가져오기
      final currentWishlistIds = Set<int>.from(_ref!.read(wishlistIdsProvider));
      LoggerUtil.d(
          '📋 위시리스트 ID 동기화 전 목록: $currentWishlistIds (${currentWishlistIds.length}개)');

      if (isLiked) {
        // 좋아요 된 경우: fundingId를 위시리스트 ID에 추가
        final alreadyExists = currentWishlistIds.contains(fundingId);
        if (alreadyExists) {
          LoggerUtil.d('ℹ️ 위시리스트 ID $fundingId는 이미 목록에 있음 (추가 필요 없음)');
        } else {
          currentWishlistIds.add(fundingId);
          LoggerUtil.d(
              '➕ 위시리스트 ID 추가: fundingId=$fundingId (현재 ${currentWishlistIds.length}개)');
        }
      } else {
        // 좋아요 취소된 경우: fundingId를 위시리스트 ID에서 제거
        final existed = currentWishlistIds.remove(fundingId);
        if (existed) {
          LoggerUtil.d(
              '🗑️ 위시리스트 ID 제거: fundingId=$fundingId (현재 ${currentWishlistIds.length}개)');
        } else {
          LoggerUtil.d('ℹ️ 위시리스트 ID $fundingId는 이미 목록에 없음 (제거 필요 없음)');
        }
      }

      // 변경 여부 확인
      final originalIds = _ref!.read(wishlistIdsProvider);
      final hasChanges = originalIds.length != currentWishlistIds.length ||
          !originalIds.containsAll(currentWishlistIds) ||
          !currentWishlistIds.containsAll(originalIds);

      // 변경이 있을 때만 상태 업데이트
      if (hasChanges) {
        LoggerUtil.i(
            '🔄 위시리스트 ID 목록 상태 업데이트: ${originalIds.length}개 → ${currentWishlistIds.length}개');
        // 위시리스트 ID 목록 상태 업데이트
        _ref!.read(wishlistIdsProvider.notifier).state = currentWishlistIds;
      } else {
        LoggerUtil.d('ℹ️ 위시리스트 ID 목록에 변경 없음 (업데이트 건너뜀)');
      }
    } catch (e) {
      LoggerUtil.e('❌ 위시리스트 ID 동기화 실패', e);
    }
  }
}

// Provider 정의
final projectViewModelProvider =
    StateNotifierProvider<ProjectViewModel, ProjectState>((ref) {
  final projectRepository = ref.watch(projectRepositoryProvider);
  final viewModel = ProjectViewModel(projectRepository);

  // Ref 설정
  viewModel.setRef(ref);

  // 로그인 상태 변경 감지 - 로그인 시 위시리스트 ID 로드
  ref.listen<bool>(isLoggedInProvider, (previous, current) {
    // 비로그인 → 로그인 상태 변경 감지
    if (previous == false && current == true) {
      LoggerUtil.i('🔐 로그인 상태 변경 감지: 위시리스트 ID 로드 시작');

      // 위시리스트 ID 로드 및 프로젝트와 매칭
      _loadWishlistIdsAndUpdateProjects(ref, viewModel);
    } else if (previous == true && current == false) {
      // 로그인 → 비로그인 상태 변경 감지
      LoggerUtil.i('🔓 로그아웃 상태 변경 감지: 위시리스트 ID 초기화');

      // 로그아웃 시 위시리스트 ID 초기화 및 좋아요 상태 모두 해제
      ref.read(wishlistIdsProvider.notifier).state = <int>{};

      // 프로젝트가 로드된 상태라면 좋아요 상태 초기화
      if (!viewModel.hasEmptyProjects) {
        viewModel.updateProjectsWithWishlistIds(<int>{});
      }
    }
  });

  // 초기 데이터 로드 전략
  Future.microtask(() async {
    // 먼저 프로젝트 로드 시작 (API 응답 대기)
    await viewModel.loadProjects();
    LoggerUtil.i('🚀 초기 프로젝트 로드 완료 - 위시리스트 ID 매칭 검사 시작');

    // 현재 로그인 상태 확인
    final isLoggedIn = ref.read(isLoggedInProvider);

    if (isLoggedIn) {
      LoggerUtil.i('🔑 앱 시작 시 로그인 상태 확인됨 - 위시리스트 ID 로드 시작');

      // 위시리스트 ID 로드 및 프로젝트와 매칭
      await _loadWishlistIdsAndUpdateProjects(ref, viewModel);
    } else {
      LoggerUtil.i('🔒 앱 시작 시 로그인 상태 아님 - 위시리스트 ID 로드 건너뜀');
    }
  });

  // 위시리스트 ID 변경 감지 및 적용
  ref.listen(wishlistIdsProvider, (prev, next) {
    LoggerUtil.d('🔄 위시리스트 ID 변경 감지: ${prev?.length ?? 0}개 → ${next.length}개');

    // 프로젝트가 로드된 상태에서만 적용
    if (!viewModel.hasEmptyProjects) {
      viewModel.updateProjectsWithWishlistIds(next);
    } else {
      LoggerUtil.w('⚠️ 프로젝트가 로드되지 않은 상태에서 위시리스트 ID 변경 감지 - 적용 보류');
    }
  });

  return viewModel;
});

// 위시리스트 ID 로드 및 프로젝트 매칭 함수 (코드 중복 제거)
Future<void> _loadWishlistIdsAndUpdateProjects(
    Ref ref, ProjectViewModel viewModel) async {
  try {
    LoggerUtil.i('🚀 위시리스트 ID 로드 및 프로젝트 매칭 시작');

    // 위시리스트 ID 로드 전 상태 확인
    final projectsBeforeUpdate = !viewModel.hasEmptyProjects
        ? '있음 (${ref.read(projectViewModelProvider).projects.length}개)'
        : '없음 (아직 로드되지 않음)';

    LoggerUtil.d('📊 위시리스트 ID 로드 전 프로젝트 상태: $projectsBeforeUpdate');

    // 위시리스트 ID 로드 (API 호출)
    await ref.read(loadWishlistIdsProvider)();

    // 현재 위시리스트 ID 상태 가져오기
    final wishlistIds = ref.read(wishlistIdsProvider);
    LoggerUtil.i('✅ 위시리스트 ID 로드 완료: ${wishlistIds.length}개');

    if (wishlistIds.isNotEmpty) {
      LoggerUtil.d('📋 로드된 위시리스트 ID 목록: $wishlistIds');
    } else {
      LoggerUtil.d('📋 로드된 위시리스트 ID 목록이 비어 있습니다.');
    }

    // 프로젝트가 로드된 상태일 때만 매칭 업데이트
    if (!viewModel.hasEmptyProjects) {
      // 위시리스트 ID로 프로젝트 좋아요 상태 업데이트
      LoggerUtil.d(
          '🔄 위시리스트 ID를 프로젝트에 매칭 시작 (${wishlistIds.length}개 ID, 프로젝트 있음)');
      viewModel.updateProjectsWithWishlistIds(wishlistIds);
    } else {
      LoggerUtil.w(
          '⚠️ 프로젝트가 로드되지 않은 상태 - 위시리스트 ID 매칭 보류 (나중에 프로젝트 로드 시 자동 적용됨)');

      // 프로젝트가 로드되지 않았지만, 위시리스트 ID는 이미 상태에 저장됨
      // 프로젝트 로드 시 updateProjectsWithWishlistIds가 호출되므로 별도 조치 필요 없음
    }
  } catch (e) {
    LoggerUtil.e('❌ 위시리스트 ID 로드 및 프로젝트 매칭 실패', e);
  }
}
