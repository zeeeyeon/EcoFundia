import { create, StateCreator } from 'zustand';
// API 호출은 api.ts 파일로 분리하는 것이 좋습니다 (추후 작업)
// import { getDashboardData as fetchDashboardApi } from './api/dashboardService';

interface DashboardStats {
    totalFunding: number;
    ongoingProducts: number;
    todayOrders: number;
}

interface ChartData {
    name: string;
    value: number;
    // 도넛 차트용 색상 추가 (선택 사항)
    fill?: string;
}

// 연령대별 통계 데이터 타입 (타입 별칭 사용)
// interface AgeGroupData extends ChartData {}
type AgeGroupData = ChartData;

// 오늘의 펀딩 모금액 데이터 타입
interface TodayFundingItem {
    id: string;
    productName: string;
    imageUrl: string; // public 폴더 기준 경로 사용
    category: string;
    totalAmount: number;
    changeAmount: number;
    fundingRate: number; // 총 펀딩률 추가
}

// 제품 데이터 타입 수정
interface Product {
    id: string;
    rank: number; // 순위
    name: string;
    totalFundingAmount: number; // 가격 (총 모금액)
    fundingRate: number; // 총 펀딩률
    // status, endDate 제거
}

interface DashboardState {
    stats: DashboardStats | null;
    fundingData: ChartData[]; // 월별 펀딩 금액 (기존)
    ageGroupData: AgeGroupData[]; // 연령대별 통계 (신규)
    todayFundingData: TodayFundingItem[]; // 오늘의 펀딩 모금액 (신규)
    products: Product[]; // 진행 중인 제품 (수정)
    isLoading: boolean;
    error: string | null;
    fetchDashboardData: () => Promise<void>;
}

const dashboardStoreCreator: StateCreator<DashboardState> = (set) => ({
    stats: null,
    fundingData: [],
    ageGroupData: [],
    todayFundingData: [],
    products: [],
    isLoading: false,
    error: null,

    fetchDashboardData: async () => {
        set({ isLoading: true, error: null });
        try {
            // 여기에 실제 API 호출 로직 추가 (api.ts의 함수 호출)
            // 예시: const data = await fetchDashboardApi();

            // 임시 목 데이터 (요구사항 반영)
            await new Promise(resolve => setTimeout(resolve, 1000));
            const mockStats = { totalFunding: 123456789, ongoingProducts: 3, todayOrders: 5 }; // ongoingProducts는 mockProducts 길이로 동적 설정 가능

            // 월별 펀딩 금액 (기존 유지, 필요시 API 연동)
            const mockFundingData = [
                { name: '1월', value: 10000000 },
                { name: '2월', value: 15000000 },
                { name: '3월', value: 12000000 },
                { name: '4월', value: 20000000 },
            ];

            // 연령대별 통계 (신규)
            const mockAgeGroupData: AgeGroupData[] = [
                { name: '10대', value: 15, fill: '#8884d8' },
                { name: '20대', value: 35, fill: '#82ca9d' },
                { name: '30대', value: 25, fill: '#ffc658' },
                { name: '40대', value: 15, fill: '#ff8042' },
                { name: '50대', value: 8, fill: '#00C49F' },
                { name: '기타', value: 2, fill: '#FFBB28' },
            ];

            // 오늘의 펀딩 모금액 목 데이터: imageUrl 경로 수정 및 fundingRate 추가
            const mockTodayFundingData: TodayFundingItem[] = [
                { id: 'tf1', productName: '오가닉 대나무 칫솔 세트', imageUrl: '/test1.png', category: '생필품', totalAmount: 1250000, changeAmount: 55000, fundingRate: 85 },
                { id: 'tf2', productName: '비건 단백질 바 (초코맛)', imageUrl: '/test2.png', category: '푸드', totalAmount: 880000, changeAmount: -10000, fundingRate: 60 },
                { id: 'tf3', productName: '스마트 재활용 분리수거함', imageUrl: '/test3.png', category: '테크', totalAmount: 2100000, changeAmount: 120000, fundingRate: 110 },
                // 상위 3개만 사용되지만 데이터 형식은 유지
                { id: 'tf4', productName: '리사이클 소재 맨투맨 티셔츠', imageUrl: '/placeholder_thumb.png', category: '패션', totalAmount: 750000, changeAmount: 30000, fundingRate: 45 },
            ];

            // 진행 중인 제품: Top 5 표시 위해 2개 추가
            const mockProducts: Product[] = [
                { id: '1', rank: 1, name: '친환경 텀블러', totalFundingAmount: 7300000, fundingRate: 73 },
                { id: '2', rank: 2, name: '대나무 칫솔 세트', totalFundingAmount: 5500000, fundingRate: 55 },
                { id: '3', rank: 3, name: '업사이클링 백팩', totalFundingAmount: 9200000, fundingRate: 92 },
                { id: '4', rank: 4, name: '고체 치약 (민트향)', totalFundingAmount: 3100000, fundingRate: 152 }, // 높은 펀딩률 예시
                { id: '5', rank: 5, name: '천연 수세미 세트', totalFundingAmount: 1800000, fundingRate: 35 },
            ];

            set({
                stats: mockStats,
                fundingData: mockFundingData,
                ageGroupData: mockAgeGroupData,
                todayFundingData: mockTodayFundingData,
                products: mockProducts,
                isLoading: false
            });
        } catch (error) {
            console.error('Failed to fetch dashboard data:', error);
            set({ error: '데이터를 불러오는데 실패했습니다.', isLoading: false });
        }
    },
});

const useDashboardStore = create(dashboardStoreCreator);

export default useDashboardStore; 