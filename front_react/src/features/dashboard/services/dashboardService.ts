import client from "../../../shared/api/client"; // 공유 클라이언트 import
// Axios 타입 import 불필요

// API 응답 타입 정의
interface ApiResponse<T> {
  status: {
    code: number;
    message: string;
  };
  content: T;
}

// 베스트 상품 응답 타입
interface TopProductItem {
  fundingId: number;
  title: string;
  price: number;
  progressPercentage: number;
}

// 오늘의 펀딩 응답 타입
interface TodayFundingItem {
  fundingId: number;
  imageUrl: string;
  title: string;
  description: string;
  currentAmount: number;
  todayAmount: number;
}

// 통계 응답 타입
interface OrderCountResponse {
  todayOrderCount: number;
}

interface FundingCountResponse {
  totalCount: number;
}

interface TotalAmountResponse {
  totalAmount: number;
}

// 연령대별 통계 응답 타입 (API 명세서 기반)
interface AgeGroupItem {
  generation: number; // 10, 20, 30, 40, 50, 60 등
  ratio: number; // 비율 (백분율)
}

// 월별 펀딩금액 응답 타입 (API 명세서 기반)
interface MonthlyAmountItem {
  month: string; // "YYYY-MM" 형식 (예: "2025-03")
  totalAmount: number; // 해당 월의 총 금액
}

// 타입 별칭 정의
type ChartDataOrder = AgeGroupItem[];
type ChartDataAmount = MonthlyAmountItem[];

// API 경로 상수 - 백엔드와 협의 후 필요시 수정
const API_PATHS = {
  CHART_DATA_AMOUNT: "/seller/month-amount-statistics",
  CHART_DATA_ORDER: "/seller/brand-statistics",
  TOP_PRODUCTS: "/seller/ongoing/top",
  TODAY_FUNDINGS: "/seller/today-order/list",
  TODAY_ORDER_COUNT: "/seller/today-order",
  FUNDING_COUNT: "/seller/total-funding/count",
  TOTAL_AMOUNT: "/seller/total-amount",
};

export const getChartDataAmount = async (): Promise<ChartDataAmount> => {
  try {
    const response = await client.get<ApiResponse<ChartDataAmount>>(
      API_PATHS.CHART_DATA_AMOUNT
    );
    return response.data.content;
  } catch (error) {
    console.error("월 펀딩액 통계 조회 실패:", error);
    // 에러 시 빈 배열 반환
    return [];
  }
};

export const getChartDataOrder = async (): Promise<ChartDataOrder> => {
  try {
    const response = await client.get<ApiResponse<ChartDataOrder>>(
      API_PATHS.CHART_DATA_ORDER
    );
    return response.data.content;
  } catch (error) {
    console.error("브랜드 통계 조회 실패:", error);
    // 에러 시 빈 배열 반환
    return [];
  }
};

/**
 * 진행 중인 펀딩 상품 리스트 (TOP5) 조회
 */
export const getTopProducts = async (): Promise<TopProductItem[]> => {
  try {
    const response = await client.get<ApiResponse<TopProductItem[]>>(
      API_PATHS.TOP_PRODUCTS
    );
    return response.data.content;
  } catch (error) {
    console.error("상위 펀딩 상품 조회 실패:", error);
    // 에러 시 빈 배열 반환
    return [];
  }
};

/**
 * 오늘의 펀딩 모금액 리스트 (최대 3개) 조회
 */
export const getTodayFundings = async (): Promise<TodayFundingItem[]> => {
  try {
    const response = await client.get<ApiResponse<TodayFundingItem[]>>(
      API_PATHS.TODAY_FUNDINGS
    );
    return response.data.content;
  } catch (error) {
    console.error("오늘의 펀딩 모금액 조회 실패:", error);
    // 에러 시 빈 배열 반환
    return [];
  }
};

/**
 * 오늘의 주문 수 조회
 */
export const getTodayOrderCount = async (): Promise<number> => {
  try {
    const response = await client.get<ApiResponse<OrderCountResponse>>(
      API_PATHS.TODAY_ORDER_COUNT
    );
    return response.data.content.todayOrderCount;
  } catch (error) {
    console.error("오늘 주문 수 조회 실패:", error);
    // 에러 시 기본값 0 반환
    return 0;
  }
};

/**
 * 진행 중인 펀딩 제품 수 조회
 */
export const getOngoingFundingCount = async (): Promise<number> => {
  try {
    const response = await client.get<ApiResponse<FundingCountResponse>>(
      API_PATHS.FUNDING_COUNT
    );
    return response.data.content.totalCount;
  } catch (error) {
    console.error("진행 중인 펀딩 제품 수 조회 실패:", error);
    // 에러 시 기본값 0 반환
    return 0;
  }
};

/**
 * 총 펀딩액 조회
 */
export const getTotalFundingAmount = async (): Promise<number> => {
  try {
    const response = await client.get<ApiResponse<TotalAmountResponse>>(
      API_PATHS.TOTAL_AMOUNT
    );
    return response.data.content.totalAmount;
  } catch (error) {
    console.error("총 펀딩액 조회 실패:", error);
    // 에러 시 기본값 0 반환
    return 0;
  }
};

/**
 * 모든 대시보드 데이터를 한번에 조회
 */
export const getAllDashboardData = async () => {
  try {
    const [
      chartDataAmount,
      chartDataOrder,
      topProducts,
      todayFundings,
      todayOrderCount,
      ongoingCount,
      totalAmount,
    ] = await Promise.all([
      getChartDataAmount(),
      getChartDataOrder(),
      getTopProducts(),
      getTodayFundings(),
      getTodayOrderCount(),
      getOngoingFundingCount(),
      getTotalFundingAmount(),
    ]);

    return {
      chartDataAmount,
      chartDataOrder,
      topProducts,
      todayFundings,
      stats: {
        todayOrderCount,
        ongoingCount,
        totalAmount,
      },
    };
  } catch (error) {
    console.error("대시보드 데이터 조회 실패:", error);
    // 에러 시 빈 데이터 반환
    return {
      chartDataAmount: [],
      chartDataOrder: [],
      topProducts: [],
      todayFundings: [],
      stats: {
        todayOrderCount: 0,
        ongoingCount: 0,
        totalAmount: 0,
      },
    };
  }
};

const dashboardService = {
  getChartDataAmount,
  getChartDataOrder,
  getTopProducts,
  getTodayFundings,
  getTodayOrderCount,
  getOngoingFundingCount,
  getTotalFundingAmount,
  getAllDashboardData,
};

export default dashboardService;
