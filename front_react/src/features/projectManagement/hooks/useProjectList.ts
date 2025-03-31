import { useEffect, useCallback } from "react";
import useProjectManagementStore from "../stores/useProjectManagementStore";
import {
  fetchOngoingProjects,
  fetchFinishedProjects,
  FetchProjectsFunction,
  Project,
} from "../services/projectManagementService";

type ProjectType = "ongoing" | "finished";

// Zustand 스토어의 타입 정의 (필요한 부분만)
type ProjectManagementState = {
  ongoing: {
    projects: Project[];
    currentPage: number;
    isLoading: boolean;
    error: string | null;
    hasNextPage: boolean;
  };
  finished: {
    projects: Project[];
    currentPage: number;
    isLoading: boolean;
    error: string | null;
    hasNextPage: boolean;
  };
  setOngoingProjects: (
    data: Project[],
    currentPage: number,
    hasNextPage: boolean
  ) => void;
  setFinishedProjects: (
    data: Project[],
    currentPage: number,
    hasNextPage: boolean
  ) => void;
  setOngoingLoading: (isLoading: boolean) => void;
  setFinishedLoading: (isLoading: boolean) => void;
  setOngoingError: (error: string | null) => void;
  setFinishedError: (error: string | null) => void;
  goToOngoingPage: (page: number) => void;
  goToFinishedPage: (page: number) => void;
  refreshProjects: () => void;
};

/**
 * 지정된 타입의 프로젝트 목록을 관리하는 커스텀 훅
 * @param projectType 'ongoing' 또는 'finished'
 */
const useProjectList = (projectType: ProjectType) => {
  // 상태 및 액션 매핑
  const stateSelectors = {
    ongoing: {
      projects: (state: ProjectManagementState) => state.ongoing.projects,
      currentPage: (state: ProjectManagementState) => state.ongoing.currentPage,
      isLoading: (state: ProjectManagementState) => state.ongoing.isLoading,
      error: (state: ProjectManagementState) => state.ongoing.error,
      hasNextPage: (state: ProjectManagementState) => state.ongoing.hasNextPage,
      setProjects: (state: ProjectManagementState) => state.setOngoingProjects,
      setLoading: (state: ProjectManagementState) => state.setOngoingLoading,
      setError: (state: ProjectManagementState) => state.setOngoingError,
      goToPage: (state: ProjectManagementState) => state.goToOngoingPage,
    },
    finished: {
      projects: (state: ProjectManagementState) => state.finished.projects,
      currentPage: (state: ProjectManagementState) =>
        state.finished.currentPage,
      isLoading: (state: ProjectManagementState) => state.finished.isLoading,
      error: (state: ProjectManagementState) => state.finished.error,
      hasNextPage: (state: ProjectManagementState) =>
        state.finished.hasNextPage,
      setProjects: (state: ProjectManagementState) => state.setFinishedProjects,
      setLoading: (state: ProjectManagementState) => state.setFinishedLoading,
      setError: (state: ProjectManagementState) => state.setFinishedError,
      goToPage: (state: ProjectManagementState) => state.goToFinishedPage,
    },
  };

  // 필요한 Zustand 상태와 액션 선택
  const selector = stateSelectors[projectType];

  const projects = useProjectManagementStore(selector.projects);
  const currentPage = useProjectManagementStore(selector.currentPage);
  const isLoading = useProjectManagementStore(selector.isLoading);
  const error = useProjectManagementStore(selector.error);
  const hasNextPage = useProjectManagementStore(selector.hasNextPage);
  const setProjects = useProjectManagementStore(selector.setProjects);
  const setLoading = useProjectManagementStore(selector.setLoading);
  const setError = useProjectManagementStore(selector.setError);
  const goToPage = useProjectManagementStore(selector.goToPage);
  const refreshAllProjects = useProjectManagementStore(
    (state) => state.refreshProjects
  );

  // API 호출 함수 선택
  const fetchFunction: FetchProjectsFunction =
    projectType === "ongoing" ? fetchOngoingProjects : fetchFinishedProjects;

  // 데이터 로드 함수 (useCallback으로 메모이제이션)
  const loadProjects = useCallback(async () => {
    setLoading(true);
    try {
      const response = await fetchFunction(currentPage);

      if (response.status.code === 200) {
        // API 응답 데이터가 비어있는지 확인하여 hasNextPage 결정
        const hasMore = !!(response.content && response.content.length > 0);
        setProjects(response.content || [], currentPage, hasMore);
      } else {
        setError(response.status.message || "상품을 불러오는데 실패했습니다.");
        // 실패 시에는 다음 페이지가 없다고 가정
        setProjects([], currentPage, false);
      }
    } catch (err) {
      console.error(`${projectType} 상품 목록 로딩 오류:`, err);
      setError("데이터 로딩 중 오류가 발생했습니다.");
      // 에러 발생 시 다음 페이지 없다고 가정
      setProjects([], currentPage, false);
    }
  }, [
    currentPage,
    fetchFunction,
    projectType,
    setLoading,
    setProjects,
    setError,
  ]);

  // 현재 페이지가 변경될 때마다 데이터 로드
  useEffect(() => {
    loadProjects();
  }, [loadProjects]);

  // isLoading이 변경될 때 데이터 다시 로드 (refreshProjects 호출 시)
  useEffect(() => {
    if (isLoading) {
      loadProjects();
    }
  }, [isLoading, loadProjects]);

  // 페이지 변경 함수
  const handlePageChange = useCallback(
    (newPage: number) => {
      // UI에서 표시되는 페이지 번호는 1부터 시작하지만, API 요청은 0부터 시작
      // newPage는 UI 기준 페이지 번호 (1, 2, 3, ...)
      // API 요청 시에는 (newPage - 1)을 사용
      const apiPage = newPage - 1; // API 요청용 페이지 인덱스로 변환 (0, 1, 2, ...)

      if (apiPage >= 0 && apiPage !== currentPage) {
        goToPage(apiPage);
      }
    },
    [currentPage, goToPage]
  );

  return {
    projects,
    currentPage,
    isLoading,
    error,
    handlePageChange,
    hasNextPage,
    refreshProjects: refreshAllProjects,
  };
};

export default useProjectList;
