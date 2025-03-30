import client from '../../../shared/api/client'; // 기존 client 임포트

// API 응답 상태 타입
export interface ApiResponseStatus {
    code: number;
    message: string;
}

// 프로젝트 공통 정보 타입
export interface Project {
    fundingId: number;
    imageUrl: string; // imageUrls에서 imageUrl로 수정 (API 응답에 맞춤)
    title: string;
    description: string;
    remainingTime: string | null; // 마감된 프로젝트는 null일 수 있음
    progressPercentage: number;
    price: number;
}

// 프로젝트 리스트 API 응답 타입
export interface ProjectListResponse {
    status: ApiResponseStatus;
    content: Project[] | null; // 데이터가 없을 경우 null일 수 있음
}

// API 호출 함수 타입
export type FetchProjectsFunction = (page: number) => Promise<ProjectListResponse>;

/**
 * 진행중인 프로젝트 리스트 조회 API 호출
 * @param page 요청할 페이지 번호 (0부터 시작)
 */
export const fetchOngoingProjects = async (page: number): Promise<ProjectListResponse> => {
    try {
        // page는 0부터 시작 (0, 1, 2, ...)
        const response = await client.get<ProjectListResponse>(`/seller/ongoing/list?page=${page}`);
        // 데이터가 없을 경우 content를 빈 배열로 처리 (API가 null을 반환할 경우 대비)
        return {
            ...response.data,
            content: response.data.content || [],
        };
    } catch (error) {
        console.error("진행중인 상품 목록 조회 오류:", error);
        // 에러 발생 시 표준 에러 응답 형식 반환
        return {
            status: { code: 500, message: "서버 오류가 발생했습니다." },
            content: [],
        };
    }
};

/**
 * 마감된 프로젝트 리스트 조회 API 호출
 * @param page 요청할 페이지 번호 (0부터 시작)
 */
export const fetchFinishedProjects = async (page: number): Promise<ProjectListResponse> => {
    try {
        // page는 0부터 시작 (0, 1, 2, ...)
        const response = await client.get<ProjectListResponse>(`/seller/end/list?page=${page}`);
        // 데이터가 없을 경우 content를 빈 배열로 처리
        return {
            ...response.data,
            content: response.data.content || [],
        };
    } catch (error) {
        console.error("마감된 상품 목록 조회 오류:", error);
        // 에러 발생 시 표준 에러 응답 형식 반환
        return {
            status: { code: 500, message: "서버 오류가 발생했습니다." },
            content: [],
        };
    }
}; 