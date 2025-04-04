// ../types.ts (수정된 내용)

// 공통 API 응답 래퍼 (변경 없음)
export interface ApiResponse<T> {
  status: {
    code: number;
    message: string;
  };
  content: T;
}

// 정산 완료된 펀딩 항목 타입 (기존 FundingReport 대체)
// API 경로: /api/seller/settlements/completed-fundings
export interface CompletedFundingReport {
  title: string; // "title": "특제 한우 육포"
  endDate: string; // "endDate": "2023-03-31T23:59:59"
  totalOrderCount: number; // "totalOrder Count": 100  (주의: 실제 키 이름 확인 필요!)
  totalAmount: number; // "totalAmount": 20000
  progressPercentage: number; // "progress Percentage": 130 (주의: 실제 키 이름 확인 필요!)
  // 기존 FundingReport의 id, fundingId, settlementDate 등은 명세서에 없으므로 제거됨
  // 필요시 백엔드에 필드 추가 요청 필요
}

// 정산 완료된 펀딩 목록 응답 타입 (기존 FundingReportsResponse 대체)
// API 경로: /api/seller/settlements/completed-fundings
export interface CompletedFundingReportsResponse {
  content: CompletedFundingReport[]; // content 배열의 타입 변경
  totalElements: number; // 페이징 정보는 실제 API 응답 확인 필요
  totalPages: number; // (PDF 명세서에는 없었음)
  currentPage: number; // (페이징 정보)
  size: number; // (페이징 정보)
  number?: number; // (페이징 정보, currentPage와 유사)
  last?: boolean; // (페이징 정보)
  first?: boolean; // (페이징 정보)
}

// 정산 예정 금액 응답 content 타입 (신규 추가)
// API 경로: /api/seller/settlements/scheduled-amount
export interface ScheduledAmountResponseContent {
  expectedAmount: number; // "expectedAmount": 8000000
}

// 총 펀딩액 응답 content 타입 (신규 추가)
// API 경로: /seller/total-amount
export interface TotalAmountResponseContent {
  totalAmount: number; // "totalAmount": 11100000
}

// 스토어 상태 타입 (Zustand, Redux 등에서 사용)
export interface FundingReportsState {
  reports: CompletedFundingReport[]; // reports의 타입 변경
  totalAmount: number | null; // 총 펀딩액 (초기값 null 가능성 고려)
  settlementAmount: number | null; // 정산 예정 금액 (초기값 null 가능성 고려)
  totalElements: number;
  totalPages: number;
  currentPage: number;
  isLoading: boolean;
  isLoadingSummary: boolean;
  error: string | null;
  // fetch 함수들은 이제 여러 API를 호출할 수 있으므로,
  // 하나의 fetchReports 대신 개별 fetch 함수 또는 통합 fetch 함수로 변경될 수 있음
  // 예시: fetchInitialData: () => Promise<void>;
  // 예시: fetchCompletedReportsPage: (page: number) => Promise<void>;
  fetchReports: (page: number) => Promise<void>; // 이 함수의 내부 구현 변경 필요
  fetchInitialData: () => Promise<void>;
  resetError: () => void;
  resetStore: () => void;
}
