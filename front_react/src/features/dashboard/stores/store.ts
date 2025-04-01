import { create, StateCreator } from "zustand";
import {
  getTopProducts,
  getTodayFundings,
  getTotalFundingAmount,
  getOngoingFundingCount,
  getTodayOrderCount,
  getChartDataAmount,
  getChartDataOrder,
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

// 연령대별 색상 맵핑
const AGE_GROUP_COLORS = {
  10: "#8884d8", // 10대 - 보라색
  20: "#82ca9d", // 20대 - 녹색
  30: "#ffc658", // 30대 - 노란색
  40: "#ff8042", // 40대 - 주황색
  50: "#00C49F", // 50대 - 청록색
  60: "#FFBB28", // 60대 - 황금색
  other: "#cccccc", // 기타 - 회색
};

// 테스트용 최소한의 더미 데이터만 제공
const generateBasicDummyData = () => {
  return {
    mockFundingData: [{ name: "1월", value: 0 }],
    mockAgeGroupData: [{ name: "데이터 없음", value: 0, fill: "#cccccc" }],
    mockTodayFundingData: [],
    mockProducts: [],
    mockStats: {
      totalFunding: 0,
      ongoingProducts: 0,
      todayOrders: 0,
    },
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
      const basicDummyData = generateBasicDummyData();

      set({
        stats: basicDummyData.mockStats,
        fundingData: basicDummyData.mockFundingData,
        ageGroupData: basicDummyData.mockAgeGroupData,
        todayFundingData: basicDummyData.mockTodayFundingData,
        products: basicDummyData.mockProducts,
        isLoading: false,
        error: "토큰이 없습니다. 로그인이 필요합니다.",
      });
      return;
    }

    try {
      // API 호출을 병렬로 처리
      const chartDataAmount = await getChartDataAmount(); // 월별 펀딩금액 데이터
      const chartDataOrder = await getChartDataOrder(); // 연령대별 통계 데이터
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

      // 연령대별 통계 데이터 변환 - API 응답 형식에 맞게 처리
      let ageGroupData: AgeGroupData[];
      if (chartDataOrder?.length > 0) {
        ageGroupData = chartDataOrder.map((item) => ({
          name: `${item.generation}대`,
          value: item.ratio,
          fill:
            AGE_GROUP_COLORS[
              item.generation as keyof typeof AGE_GROUP_COLORS
            ] || AGE_GROUP_COLORS.other,
        }));
      } else {
        console.warn("연령대별 통계 데이터가 없습니다.");
        ageGroupData = [{ name: "데이터 없음", value: 0, fill: "#cccccc" }];
      }

      // 월별 펀딩 금액 데이터 변환 - API 응답 형식에 맞게 처리
      let fundingData: ChartData[];
      if (chartDataAmount?.length > 0) {
        fundingData = chartDataAmount.map((item) => {
          // "YYYY-MM" 형식에서 월만 추출하여 "M월" 형식으로 변환
          const month = parseInt(item.month.split("-")[1], 10);
          return {
            name: `${month}월`,
            value: item.totalAmount,
          };
        });

        // 월별 순서로 정렬
        fundingData.sort((a, b) => {
          const monthA = parseInt(a.name.replace("월", ""), 10);
          const monthB = parseInt(b.name.replace("월", ""), 10);
          return monthA - monthB;
        });
      } else {
        console.warn("월별 펀딩 금액 데이터가 없습니다.");
        fundingData = [{ name: "데이터 없음", value: 0 }];
      }

      // TOP5 제품 데이터 변환
      let products: Product[] = [];
      if (topProductsData?.length > 0) {
        products = topProductsData.map((item, index) => ({
          id: item.fundingId ? item.fundingId.toString() : `product-${index}`,
          rank: index + 1,
          name: item.title || `제품 ${index + 1}`,
          totalFundingAmount: item.price || 0,
          fundingRate: item.progressPercentage || 0,
        }));
      }

      // 오늘의 펀딩 데이터 변환
      let todayFundingData: TodayFundingItem[] = [];
      if (todayFundingsData?.length > 0) {
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
      }

      // 최종 상태 업데이트
      set({
        stats,
        fundingData,
        ageGroupData,
        todayFundingData,
        products,
        isLoading: false,
        error: null,
      });
    } catch (error) {
      console.error("대시보드 데이터 조회 오류:", error);
      set({
        isLoading: false,
        error: "데이터를 불러오는 중 오류가 발생했습니다.",
      });
    }
  },
});

const useDashboardStore = create<DashboardState>(dashboardStoreCreator);

export default useDashboardStore;
