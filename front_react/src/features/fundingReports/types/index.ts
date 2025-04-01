// API 응답 타입
export interface ApiResponse<T> {
  status: {
    code: number;
    message: string;
  };
  content: T;
}

// 정산내역 아이템 타입
export interface FundingReport {
  id: number; // 정산 내역 ID
  fundingId: number; // 펀딩 ID
  productName: string; // 상품명
  settlementDate: string; // 정산(예정)일
  orderCount: number; // 주문 수
  totalFunding: number; // 총 펀딩액
  fundingRate: number; // 펀딩률 (%)
}

// 페이지네이션 응답 타입
export interface FundingReportsResponse {
  content: FundingReport[];
  totalElements: number;
  totalPages: number;
  currentPage: number;
  size: number;
  number?: number;
  last?: boolean;
  first?: boolean;
}

// 요약 정보 타입
export interface FundingReportSummary {
  totalAmount: number; // 총 펀딩 금액
  settlementAmount: number; // 정산 예정 금액
}

// 스토어 상태 타입
export interface FundingReportsState {
  reports: FundingReport[];
  totalAmount: number;
  settlementAmount: number;
  totalElements: number;
  totalPages: number;
  currentPage: number;
  isLoading: boolean;
  error: string | null;
  fetchReports: (page: number) => Promise<void>;
  resetError: () => void;
  resetStore: () => void;
}
