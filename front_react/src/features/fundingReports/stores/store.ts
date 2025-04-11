import { create } from "zustand";
import { FundingReportsState } from "../types";
import {
  getCompletedFundingReports,
  getScheduledAmount,
  getTotalFundingAmount,
} from "../services/fundingReportsService";
import { getTokens } from "../../../shared/utils/auth";

const useFundingReportsStore = create<FundingReportsState>((set, get) => ({
  // 초기 상태
  reports: [],
  totalAmount: null,
  settlementAmount: null,
  totalElements: 0,
  totalPages: 0,
  currentPage: 0,
  isLoading: false,
  isLoadingSummary: false,
  error: null,

  fetchReports: async (page: number) => {
    // 이미 해당 페이지를 로딩 중이면 중복 호출 방지
    if (get().currentPage === page && get().isLoading) {
      return;
    }

    set({ isLoading: true, error: null });

    try {
      const tokens = getTokens();
      if (!tokens) {
        throw new Error("로그인이 필요합니다.");
      }

      const reportsData = await getCompletedFundingReports(page);

      set({
        reports: reportsData.content,
        totalElements: reportsData.totalElements,
        totalPages: reportsData.totalPages,
        currentPage: page,
        isLoading: false,
      });
    } catch (error) {
      console.error(`정산내역 ${page}페이지 로딩 중 오류 발생:`, error);
      set({
        isLoading: false,
        error:
          error instanceof Error
            ? error.message
            : `페이지 ${page}를 불러오는데 실패했습니다.`,
      });
    }
  },

  fetchInitialData: async () => {
    // 이미 데이터가 있거나 로딩 중이면 중복 호출 방지
    if (get().isLoadingSummary) {
      return;
    }

    set({ isLoadingSummary: true, error: null });

    try {
      const tokens = getTokens();
      if (!tokens) {
        throw new Error("로그인이 필요합니다.");
      }

      // Promise.all을 사용하지 않고 개별적으로 호출하여 에러 처리
      let totalAmountData = 0;
      let scheduledAmountData = 0;

      try {
        totalAmountData = await getTotalFundingAmount();
        console.log("성공적으로 총 펀딩액을 가져왔습니다:", totalAmountData);
      } catch (error) {
        console.error("총 펀딩액 가져오기 실패:", error);
        // 실패해도 계속 진행
      }

      try {
        scheduledAmountData = await getScheduledAmount();
        console.log(
          "성공적으로 정산 예정 금액을 가져왔습니다:",
          scheduledAmountData
        );
      } catch (error) {
        console.error("정산 예정 금액 가져오기 실패:", error);
        // 실패해도 계속 진행
      }

      console.log("받아온 데이터:", { totalAmountData, scheduledAmountData });
      console.log("현재 스토어 상태:", get());

      set({
        totalAmount: totalAmountData,
        settlementAmount: scheduledAmountData,
        isLoadingSummary: false,
      });

      console.log("업데이트 후 스토어 상태:", get());
    } catch (error) {
      console.error("초기 정산 데이터 로딩 중 오류 발생:", error);
      set({
        isLoadingSummary: false,
        error:
          error instanceof Error
            ? error.message
            : "초기 정보를 불러오는데 실패했습니다.",
      });
    }
  },

  resetError: () => set({ error: null }),

  resetStore: () =>
    set({
      reports: [],
      totalAmount: null,
      settlementAmount: null,
      totalElements: 0,
      totalPages: 0,
      currentPage: 0,
      isLoading: false,
      isLoadingSummary: false,
      error: null,
    }),
}));

export default useFundingReportsStore;
