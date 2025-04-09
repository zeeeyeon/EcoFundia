import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:front/features/home/data/repositories/project_repository_impl.dart';
import 'package:front/features/home/domain/repositories/project_repository.dart';
import 'package:front/features/home/domain/entities/project_entity.dart';
import 'package:front/utils/logger_util.dart';
import 'package:front/features/wishlist/ui/view_model/wishlist_provider.dart';
import 'package:front/core/providers/app_state_provider.dart';
import 'package:flutter/foundation.dart';

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
  DateTime? _lastLoadTime; // 마지막 데이터 로드 시간 추적
  final Ref _ref; // Ref 저장 (위시리스트 업데이트 및 로드를 위해)

  ProjectViewModel(this._projectRepository, this._ref)
      : super(ProjectState(projects: []));

  // 프로젝트 목록이 비어있는지 확인하는 getter
  bool get hasEmptyProjects => state.projects.isEmpty;

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
      // Ref가 있는 경우에만 위시리스트 ID 가져오기
      LoggerUtil.d('🔍 현재 위시리스트 ID 목록 읽기 시작');
      wishlistIds = Set<int>.from(_ref.read(wishlistIdsProvider));
      LoggerUtil.d('📋 현재 위시리스트 ID 목록: $wishlistIds (${wishlistIds.length}개)');

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

      state = state.copyWith(
        projects: updatedProjects, // 위시리스트 ID와 매칭된 상태로 업데이트
        isLoading: false,
      );
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
    // Check if projects are loaded before proceeding
    if (state.projects.isEmpty) {
      LoggerUtil.w('[ProjectViewModel] 프로젝트 목록이 비어있어 위시리스트 업데이트 건너뜀.');
      return; // Return current state without modification
    }

    LoggerUtil.i('[ProjectViewModel] 위시리스트 ID로 프로젝트 좋아요 상태 업데이트 시작');
    LoggerUtil.d('[ProjectViewModel] 적용할 ID 목록: $wishlistIds');

    // --- Proceed with updating isLiked status ---
    // Directly use the current state (state.projects)
    // No need to read(projectViewModelProvider)
    final updatedProjects = state.projects.map((project) {
      final isLiked = wishlistIds.contains(project.id);
      // Only create a new object if the state actually changed
      if (project.isLiked != isLiked) {
        LoggerUtil.d(
            '[ProjectViewModel] 프로젝트 ID ${project.id} 상태 변경: ${project.isLiked} -> $isLiked');
        return project.copyWith(isLiked: isLiked);
      }
      return project;
    }).toList();

    // Check if the list instance or content has actually changed
    if (!identical(state.projects, updatedProjects) &&
        !listEquals(state.projects, updatedProjects)) {
      LoggerUtil.i('[ProjectViewModel] 프로젝트 위시리스트 상태 업데이트 적용.');
      // Update the state with the new list
      state = state.copyWith(projects: updatedProjects);
    } else {
      LoggerUtil.d('[ProjectViewModel] 위시리스트 상태 변경 없음, 업데이트 건너뜀.');
    }
  }

  // 좋아요 토글
  Future<void> toggleLike(ProjectEntity project) async {
    final originalProjects = List<ProjectEntity>.from(state.projects);
    final projectIndex = state.projects.indexWhere((p) => p.id == project.id);

    if (projectIndex == -1) {
      LoggerUtil.w('⚠️ 좋아요 토글: 프로젝트 ID ${project.id}를 찾을 수 없음');
      return;
    }

    final originalIsLiked = project.isLiked;
    final fundingId = project.id;

    LoggerUtil.i(
        '🔄 프로젝트 ID $fundingId 좋아요 토글 시작 ($originalIsLiked → ${!originalIsLiked})');

    // 1. Optimistic UI 업데이트
    final updatedProjects = List<ProjectEntity>.from(state.projects);
    updatedProjects[projectIndex] = project.copyWith(isLiked: !originalIsLiked);
    state = state.copyWith(projects: updatedProjects);
    LoggerUtil.d('🔄 좋아요 토글: Optimistic UI 업데이트 적용');

    try {
      // 2. API 호출
      LoggerUtil.d('📡 API 호출: 위시리스트 토글 요청 (ID: $fundingId)');
      await _projectRepository.toggleProjectLike(fundingId,
          isCurrentlyLiked: originalIsLiked);
      LoggerUtil.i('✅ API 응답 성공: 프로젝트 ID $fundingId 토글 완료');

      // 3. 위시리스트 ID 상태 동기화 (변경된 상태 반영)
      _syncWishlistIds(fundingId, !originalIsLiked);
    } catch (e) {
      LoggerUtil.e('❌ API 오류: 프로젝트 ID $fundingId 토글 실패', e);
      // 4. 실패 시 UI 롤백
      LoggerUtil.d('🔄 API 오류로 인한 UI 롤백');
      state = state.copyWith(
        projects: originalProjects,
        error: '찜 상태 변경에 실패했습니다.', // 에러 메시지 설정
      );
      // 실패 시 위시리스트 상태도 롤백 고려 (선택 사항)
      // _syncWishlistIds(fundingId, originalIsLiked);
    }
  }

  /// 위시리스트 상태 변경 시 ProjectViewModel의 상태와 동기화
  void _syncWishlistIds(int projectId, bool isLiked) {
    try {
      final currentIds = _ref.read(wishlistIdsProvider).toSet(); // 복사본 사용
      if (isLiked) {
        if (currentIds.add(projectId)) {
          // 변경이 있었는지 확인
          _ref.read(wishlistIdsProvider.notifier).state = currentIds;
          LoggerUtil.d('🔄 위시리스트 ID 추가 동기화: $projectId');
        }
      } else {
        if (currentIds.remove(projectId)) {
          // 변경이 있었는지 확인
          _ref.read(wishlistIdsProvider.notifier).state = currentIds;
          LoggerUtil.d('🔄 위시리스트 ID 제거 동기화: $projectId');
        }
      }
    } catch (e) {
      // Provider가 dispose되었거나 할 때 오류 발생 가능성 있음
      LoggerUtil.e('❌ 위시리스트 ID 동기화 중 오류', e);
    }
  }

  // 에러 상태 초기화
  void clearError() {
    if (state.error != null) {
      state = state.copyWith(error: null);
      LoggerUtil.d('🔄 에러 상태 초기화');
    }
  }

  // 프로젝트 목록 새로고침
  Future<void> refreshProjects() async {
    LoggerUtil.i('🔄 프로젝트 목록 새로고침 시작');
    // 마지막 로드 시간 초기화하여 즉시 로드 가능하게 함
    _lastLoadTime = null;
    // 로드 함수 호출
    await loadProjects();
    LoggerUtil.i('✅ 프로젝트 목록 새로고침 완료');
  }
}

// ProjectViewModel Provider 정의
final projectViewModelProvider =
    StateNotifierProvider<ProjectViewModel, ProjectState>((ref) {
  final projectRepository = ref.watch(projectRepositoryProvider);
  final viewModel = ProjectViewModel(projectRepository, ref); // Pass ref

  // 위시리스트 ID 변경 감지 리스너 설정
  ref.listen<Set<int>>(wishlistIdsProvider, (previous, next) {
    LoggerUtil.i(
        '[ProjectViewModel Listener] 위시리스트 ID 변경 감지 (${previous?.length} -> ${next.length})');
    // ViewModel의 상태 업데이트 메서드 호출
    viewModel.updateProjectsWithWishlistIds(next);
  });

  // 앱 상태 변경(로그인/로그아웃) 감지 리스너 설정
  ref.listen<AppState>(appStateProvider, (previous, next) {
    // 로그인 상태로 변경되었을 때 프로젝트 새로고침 (찜 상태 반영 위함)
    if (previous != null && !previous.isLoggedIn && next.isLoggedIn) {
      LoggerUtil.i('[ProjectViewModel Listener] 로그인 감지, 프로젝트 새로고침');
      viewModel.refreshProjects();
    }
    // 로그아웃 상태로 변경되었을 때 프로젝트의 isLiked 상태 초기화
    else if (previous != null && previous.isLoggedIn && !next.isLoggedIn) {
      LoggerUtil.i('[ProjectViewModel Listener] 로그아웃 감지, 프로젝트 isLiked 초기화');
      // 로그아웃 시에는 위시리스트 ID가 비어있을 것이므로 빈 Set으로 업데이트 호출
      viewModel.updateProjectsWithWishlistIds({});
    }
  });

  return viewModel;
});
