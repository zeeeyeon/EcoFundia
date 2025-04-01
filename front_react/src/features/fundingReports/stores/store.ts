import { create } from "zustand";
import { FundingReportsState } from "../types";
import {
  getFundingReports,
  getReportsSummary,
  generateDummyData,
} from "../services/fundingReportsService";
import { getTokens } from "../../../shared/utils/auth";

// 더미 데이터 (API 미구현 시 사용)
const { dummySummary, getPaginatedDummyReports } = generateDummyData();

const useFundingReportsStore = create<FundingReportsState>((set) => ({
  // 초기 상태
  reports: [],
  totalAmount: 0,
  settlementAmount: 0,
  totalElements: 0,
  totalPages: 0,
  currentPage: 0,
  isLoading: false,
  error: null,

  // 정산내역 조회 함수
  fetchReports: async (page: number) => {
    set({ isLoading: true, error: null });

    try {
      // 토큰 확인 (로그인 상태 확인)
      const tokens = getTokens();
      if (!tokens) {
        // 개발 모드에서 더미 데이터 사용
        console.warn(
          "토큰이 없습니다. 개발 모드에서 더미 데이터를 사용합니다."
        );

        // 페이지네이션된 더미 데이터 가져오기
        const dummyData = getPaginatedDummyReports(page);

        set({
          reports: dummyData.content,
          totalElements: dummyData.totalElements,
          totalPages: dummyData.totalPages,
          currentPage: page,
          totalAmount: dummySummary.totalAmount,
          settlementAmount: dummySummary.settlementAmount,
          isLoading: false,
        });
        return;
      }

      // API 호출 (실제 데이터 가져오기)
      const [reportsData, summaryData] = await Promise.all([
        getFundingReports(page),
        getReportsSummary(),
      ]);

      set({
        reports: reportsData.content,
        totalElements: reportsData.totalElements,
        totalPages: reportsData.totalPages,
        currentPage: page,
        totalAmount: summaryData.totalAmount,
        settlementAmount: summaryData.settlementAmount,
        isLoading: false,
      });
    } catch (error) {
      console.error("정산내역 데이터 로딩 중 오류 발생:", error);

      // 에러 발생 시 더미 데이터로 대체
      const dummyData = getPaginatedDummyReports(page);

      set({
        reports: dummyData.content,
        totalElements: dummyData.totalElements,
        totalPages: dummyData.totalPages,
        currentPage: page,
        totalAmount: dummySummary.totalAmount,
        settlementAmount: dummySummary.settlementAmount,
        isLoading: false,
        error:
          error instanceof Error
            ? error.message
            : "정산내역을 불러오는데 실패했습니다.",
      });
    }
  },

  // 에러 상태 초기화 함수
  resetError: () => set({ error: null }),

  // 스토어 초기화 함수
  resetStore: () =>
    set({
      reports: [],
      totalAmount: 0,
      settlementAmount: 0,
      totalElements: 0,
      totalPages: 0,
      currentPage: 0,
      isLoading: false,
      error: null,
    }),
}));

export default useFundingReportsStore;
