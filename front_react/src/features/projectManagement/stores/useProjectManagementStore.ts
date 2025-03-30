import { create } from 'zustand';
import { Project } from '../services/projectManagementService';

interface ProjectListState {
    projects: Project[];
    currentPage: number;
    isLoading: boolean;
    error: string | null;
    hasNextPage: boolean; // 다음 페이지 존재 여부
}

interface ProjectManagementStore {
    ongoing: ProjectListState;
    finished: ProjectListState;
    setOngoingProjects: (data: Project[], currentPage: number, hasNextPage: boolean) => void;
    setFinishedProjects: (data: Project[], currentPage: number, hasNextPage: boolean) => void;
    setOngoingLoading: (isLoading: boolean) => void;
    setFinishedLoading: (isLoading: boolean) => void;
    setOngoingError: (error: string | null) => void;
    setFinishedError: (error: string | null) => void;
    goToOngoingPage: (page: number) => void;
    goToFinishedPage: (page: number) => void;
    resetStore: () => void; // 상태 초기화 함수
}

const initialProjectListState: ProjectListState = {
    projects: [],
    currentPage: 0,
    isLoading: false,
    error: null,
    hasNextPage: true, // 초기에는 다음 페이지가 있다고 가정
};

const useProjectManagementStore = create<ProjectManagementStore>((set) => ({
    ongoing: { ...initialProjectListState },
    finished: { ...initialProjectListState },

    setOngoingProjects: (projects, currentPage, hasNextPage) => set((state) => ({
        ongoing: { ...state.ongoing, projects, currentPage, isLoading: false, error: null, hasNextPage },
    })),

    setFinishedProjects: (projects, currentPage, hasNextPage) => set((state) => ({
        finished: { ...state.finished, projects, currentPage, isLoading: false, error: null, hasNextPage },
    })),

    setOngoingLoading: (isLoading) => set((state) => ({
        ongoing: { ...state.ongoing, isLoading, error: isLoading ? null : state.ongoing.error }, // 로딩 시작 시 에러 초기화
    })),

    setFinishedLoading: (isLoading) => set((state) => ({
        finished: { ...state.finished, isLoading, error: isLoading ? null : state.finished.error }, // 로딩 시작 시 에러 초기화
    })),

    setOngoingError: (error) => set((state) => ({
        ongoing: { ...state.ongoing, error, isLoading: false },
    })),

    setFinishedError: (error) => set((state) => ({
        finished: { ...state.finished, error, isLoading: false },
    })),

    // 페이지 변경 시 로딩 상태는 변경하지 않고 currentPage만 업데이트 (실제 데이터 로딩은 훅에서 처리)
    goToOngoingPage: (page) => set((state) => ({
        ongoing: { ...state.ongoing, currentPage: page },
    })),

    goToFinishedPage: (page) => set((state) => ({
        finished: { ...state.finished, currentPage: page },
    })),

    resetStore: () => set({
        ongoing: { ...initialProjectListState },
        finished: { ...initialProjectListState }
    }),
}));

export default useProjectManagementStore; 