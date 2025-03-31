import client from '../../../shared/api/client'; // 공유 클라이언트 import
// Axios 타입 import 불필요

// API 함수 타입 정의 (예시)
interface DashboardData {
    stats: { totalFunding: number; ongoingProducts: number; todayOrders: number };
    usageData: { name: string; value: number }[];
    fundingData: { name: string; value: number }[];
    products: { id: string; name: string; status: string; progress: number; endDate: string }[];
}

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

// API 경로 상수 - 백엔드와 협의 후 필요시 수정
const API_PATHS = {
    TOP_PRODUCTS: '/seller/ongoing/top',
    TODAY_FUNDINGS: '/seller/today-order/list',
    TODAY_ORDER_COUNT: '/seller/today-order',
    FUNDING_COUNT: '/seller/total-funding/count',
    TOTAL_AMOUNT: '/seller/total-amount'
};

// 개발 중 더미 데이터 (임시)
const DUMMY_DATA = {
    // 오늘의 펀딩 모금액 3개 (TODAY_FUNDINGS 전용 더미 데이터)
    todayFundings: [
        {
            fundingId: 101,
            imageUrl: '/test1.png',
            title: '오가닉 대나무 칫솔 세트',
            description: '생필품',
            currentAmount: 1250000,
            todayAmount: 55000
        },
        {
            fundingId: 102,
            imageUrl: '/test2.png',
            title: '비건 단백질 바 (초코맛)',
            description: '푸드',
            currentAmount: 880000,
            todayAmount: -10000
        },
        {
            fundingId: 103,
            imageUrl: '/test3.png',
            title: '스마트 재활용 분리수거함',
            description: '테크',
            currentAmount: 2100000,
            todayAmount: 120000
        }
    ]
};

// 대시보드 데이터 가져오는 함수
const getDashboardData = async (): Promise<DashboardData> => {
    try {
        // 실제 API endpoint로 변경 필요
        // apiInstance 대신 client 사용
        const response = await client.get<DashboardData>('/mock/dashboard'); // 예시 endpoint
        return response.data;
    } catch (error) {
        console.error('Failed to get dashboard data:', error);
        // 실제 에러 처리 로직 추가 (예: 사용자에게 알림)
        throw error;
    }
};

/**
 * 진행 중인 펀딩 상품 리스트 (TOP5) 조회
 */
export const getTopProducts = async (): Promise<TopProductItem[]> => {
    try {
        const response = await client.get<ApiResponse<TopProductItem[]>>(API_PATHS.TOP_PRODUCTS);
        return response.data.content;
    } catch (error) {
        console.error('상위 펀딩 상품 조회 실패:', error);
        // 에러 시 빈 배열 반환
        return [];
    }
};

/**
 * 오늘의 펀딩 모금액 리스트 (최대 3개) 조회
 * 백엔드 API 완성 전까지 더미 데이터 사용
 */
export const getTodayFundings = async (): Promise<TodayFundingItem[]> => {
    // 오늘의 펀딩 API는 현재 서버 오류로 더미 데이터 사용
    console.info('오늘의 펀딩 모금액 더미 데이터 사용 (서버 오류로 인한 임시 조치)');
    return DUMMY_DATA.todayFundings;

    /* 서버 API 준비되면 아래 코드 사용
    try {
        const response = await client.get<ApiResponse<TodayFundingItem[]>>(API_PATHS.TODAY_FUNDINGS);
        return response.data.content;
    } catch (error) {
        console.error('오늘의 펀딩 모금액 조회 실패:', error);
        // 에러 시 빈 배열 반환
        return [];
    }
    */
};

/**
 * 오늘의 주문 수 조회
 */
export const getTodayOrderCount = async (): Promise<number> => {
    try {
        const response = await client.get<ApiResponse<OrderCountResponse>>(API_PATHS.TODAY_ORDER_COUNT);
        return response.data.content.todayOrderCount;
    } catch (error) {
        console.error('오늘 주문 수 조회 실패:', error);
        // 에러 시 기본값 0 반환
        return 0;
    }
};

/**
 * 진행 중인 펀딩 제품 수 조회
 */
export const getOngoingFundingCount = async (): Promise<number> => {
    try {
        const response = await client.get<ApiResponse<FundingCountResponse>>(API_PATHS.FUNDING_COUNT);
        return response.data.content.totalCount;
    } catch (error) {
        console.error('진행 중인 펀딩 제품 수 조회 실패:', error);
        // 에러 시 기본값 0 반환
        return 0;
    }
};

/**
 * 총 펀딩액 조회
 */
export const getTotalFundingAmount = async (): Promise<number> => {
    try {
        const response = await client.get<ApiResponse<TotalAmountResponse>>(API_PATHS.TOTAL_AMOUNT);
        return response.data.content.totalAmount;
    } catch (error) {
        console.error('총 펀딩액 조회 실패:', error);
        // 에러 시 기본값 0 반환
        return 0;
    }
};

/**
 * 모든 대시보드 데이터를 한번에 조회
 */
export const getAllDashboardData = async () => {
    try {
        const [topProducts, todayFundings, todayOrderCount, ongoingCount, totalAmount] = await Promise.all([
            getTopProducts(),
            getTodayFundings(),
            getTodayOrderCount(),
            getOngoingFundingCount(),
            getTotalFundingAmount()
        ]);

        return {
            topProducts,
            todayFundings,
            stats: {
                todayOrderCount,
                ongoingCount,
                totalAmount
            }
        };
    } catch (error) {
        console.error('대시보드 데이터 조회 실패:', error);
        // 에러 시 빈 데이터 반환
        return {
            topProducts: [],
            todayFundings: [],
            stats: {
                todayOrderCount: 0,
                ongoingCount: 0,
                totalAmount: 0
            }
        };
    }
};

const dashboardService = {
    getDashboardData,
    getTopProducts,
    getTodayFundings,
    getTodayOrderCount,
    getOngoingFundingCount,
    getTotalFundingAmount,
    getAllDashboardData,
    // 다른 대시보드 관련 API 함수들 추가...
};

export default dashboardService; 