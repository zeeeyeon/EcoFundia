import { create, StateCreator } from "zustand";
import {
  getTopProducts,
  getTodayFundings,
  getTotalFundingAmount,
  getOngoingFundingCount,
  getTodayOrderCount,
} from "../services/dashboardService";
import { getTokens } from "../../../shared/utils/auth";

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

// 더미 데이터 생성 함수
const generateDummyData = () => {
  // 월별 펀딩 금액 (차트용 더미 데이터)
  const mockFundingData = [
    { name: "1월", value: 10000000 },
    { name: "2월", value: 15000000 },
    { name: "3월", value: 12000000 },
    { name: "4월", value: 20000000 },
  ];

  // 연령대별 통계 (차트용 더미 데이터)
  const mockAgeGroupData: AgeGroupData[] = [
    { name: "10대", value: 15, fill: "#8884d8" },
    { name: "20대", value: 35, fill: "#82ca9d" },
    { name: "30대", value: 25, fill: "#ffc658" },
    { name: "40대", value: 15, fill: "#ff8042" },
    { name: "50대", value: 8, fill: "#00C49F" },
    { name: "기타", value: 2, fill: "#FFBB28" },
  ];

  // 오늘의 펀딩 모금액 목 데이터
  const mockTodayFundingData: TodayFundingItem[] = [
    {
      id: "tf1",
      productName: "오가닉 대나무 칫솔 세트",
      imageUrl: "/test1.png",
      category: "생필품",
      totalAmount: 1250000,
      changeAmount: 55000,
      fundingRate: 85,
    },
    {
      id: "tf2",
      productName: "비건 단백질 바 (초코맛)",
      imageUrl: "/test2.png",
      category: "푸드",
      totalAmount: 880000,
      changeAmount: -10000,
      fundingRate: 60,
    },
    {
      id: "tf3",
      productName: "스마트 재활용 분리수거함",
      imageUrl: "/test3.png",
      category: "테크",
      totalAmount: 2100000,
      changeAmount: 120000,
      fundingRate: 110,
    },
  ];

  // 진행 중인 제품 Top 5
  const mockProducts: Product[] = [
    {
      id: "1",
      rank: 1,
      name: "친환경 텀블러",
      totalFundingAmount: 7300000,
      fundingRate: 73,
    },
    {
      id: "2",
      rank: 2,
      name: "대나무 칫솔 세트",
      totalFundingAmount: 5500000,
      fundingRate: 55,
    },
    {
      id: "3",
      rank: 3,
      name: "업사이클링 백팩",
      totalFundingAmount: 9200000,
      fundingRate: 92,
    },
    {
      id: "4",
      rank: 4,
      name: "고체 치약 (민트향)",
      totalFundingAmount: 3100000,
      fundingRate: 152,
    },
    {
      id: "5",
      rank: 5,
      name: "천연 수세미 세트",
      totalFundingAmount: 1800000,
      fundingRate: 35,
    },
  ];

  // 대시보드 통계
  const mockStats: DashboardStats = {
    totalFunding: 123456789,
    ongoingProducts: 5,
    todayOrders: 8,
  };

  return {
    mockFundingData,
    mockAgeGroupData,
    mockTodayFundingData,
    mockProducts,
    mockStats,
  };
};

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

    // 토큰 확인
    const tokens = getTokens();
    if (!tokens) {
      const {
        mockFundingData,
        mockAgeGroupData,
        mockTodayFundingData,
        mockProducts,
        mockStats,
      } = generateDummyData();

      set({
        stats: mockStats,
        fundingData: mockFundingData,
        ageGroupData: mockAgeGroupData,
        todayFundingData: mockTodayFundingData,
        products: mockProducts,
        isLoading: false,
        error: "토큰이 없습니다. 개발 모드에서 테스트 데이터를 사용합니다.",
      });
      return;
    }

    // API 호출을 개별적으로 처리하여 실패하더라도 다른 API 요청에 영향을 주지 않음
    try {
      // 차트 데이터 - 현재는 API가 없어 더미 데이터 사용
      const { mockFundingData, mockAgeGroupData } = generateDummyData();

      // 모든 API 호출을 개별적으로 처리
      const topProductsData = await getTopProducts();
      const todayFundingsData = await getTodayFundings();
      const totalFunding = await getTotalFundingAmount();
      const ongoingProducts = await getOngoingFundingCount();
      const todayOrders = await getTodayOrderCount();

      // 통계 데이터
      const stats: DashboardStats = {
        totalFunding,
        ongoingProducts,
        todayOrders,
      };

      // TOP5 제품 데이터 변환 - 데이터가 없으면 더미 데이터 사용
      let products: Product[];
      if (topProductsData.length > 0) {
        products = topProductsData.map((item, index) => ({
          id: item.fundingId ? item.fundingId.toString() : `product-${index}`,
          rank: index + 1,
          name: item.title || `제품 ${index + 1}`,
          totalFundingAmount: item.price || 0,
          fundingRate: item.progressPercentage || 0,
        }));
      } else {
        console.warn("상위 제품 데이터가 없습니다. 더미 데이터를 사용합니다.");
        products = generateDummyData().mockProducts;
      }

      // 오늘의 펀딩 데이터 변환 - 데이터가 없으면 더미 데이터 사용
      let todayFundingData: TodayFundingItem[];
      if (todayFundingsData.length > 0) {
        todayFundingData = todayFundingsData.map((item, index) => ({
          id: item.fundingId ? item.fundingId.toString() : `funding-${index}`,
          productName: item.title || "제품명 없음",
          imageUrl: item.imageUrl || "/placeholder_thumb.png",
          category: item.description || "기타",
          totalAmount: item.currentAmount || 0,
          changeAmount: item.todayAmount || 0,
          fundingRate: Math.round(
            (item.currentAmount /
              (item.currentAmount - item.todayAmount || 1)) *
              100 || 0
          ),
        }));
      } else {
        console.warn(
          "오늘의 펀딩 데이터가 없습니다. 더미 데이터를 사용합니다."
        );
        todayFundingData = generateDummyData().mockTodayFundingData;
      }

      set({
        stats,
        fundingData: mockFundingData,
        ageGroupData: mockAgeGroupData,
        todayFundingData,
        products,
        isLoading: false,
        error: null,
      });
    } catch (error) {
      console.error("대시보드 데이터 조회 중 오류가 발생했습니다:", error);

      // 모든 API 실패 시 더미 데이터 사용
      const {
        mockFundingData,
        mockAgeGroupData,
        mockTodayFundingData,
        mockProducts,
        mockStats,
      } = generateDummyData();

      set({
        stats: mockStats,
        fundingData: mockFundingData,
        ageGroupData: mockAgeGroupData,
        todayFundingData: mockTodayFundingData,
        products: mockProducts,
        isLoading: false,
        error:
          "데이터를 불러오는데 실패했습니다. 개발 모드에서 테스트 데이터를 사용합니다.",
      });
    }
  },
});

const useDashboardStore = create(dashboardStoreCreator);

export default useDashboardStore;
