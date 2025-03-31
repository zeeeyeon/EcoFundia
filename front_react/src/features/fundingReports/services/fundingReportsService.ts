import client from "../../../shared/api/client";
import {
  ApiResponse,
  FundingReport,
  FundingReportsResponse,
  FundingReportSummary,
} from "../types";

// API 경로
const API_PATHS = {
  REPORTS_LIST: "/seller/settlement/list",
  REPORTS_SUMMARY: "/seller/settlement/summary",
};

/**
 * 정산내역 목록 조회
 * @param page 페이지 번호 (0부터 시작)
 */
export const getFundingReports = async (
  page: number
): Promise<FundingReportsResponse> => {
  try {
    const response = await client.get<ApiResponse<FundingReportsResponse>>(
      `${API_PATHS.REPORTS_LIST}?page=${page}&size=5`
    );
    return response.data.content;
  } catch (error) {
    console.error("정산내역 목록 조회 중 오류 발생:", error);
    throw new Error("정산내역을 불러오는데 실패했습니다.");
  }
};

/**
 * 정산내역 요약 정보 조회
 */
export const getReportsSummary = async (): Promise<FundingReportSummary> => {
  try {
    const response = await client.get<ApiResponse<FundingReportSummary>>(
      API_PATHS.REPORTS_SUMMARY
    );
    return response.data.content;
  } catch (error) {
    console.error("정산내역 요약 정보 조회 중 오류 발생:", error);
    throw new Error("정산내역 요약 정보를 불러오는데 실패했습니다.");
  }
};

/**
 * API가 없는 경우 사용할 더미 데이터 생성 함수
 */
export const generateDummyData = () => {
  // 더미 정산내역 목록
  const dummyReports: FundingReport[] = [
    {
      id: 1001,
      fundingId: 1001,
      productName: "오가닉 대나무 칫솔 세트",
      settlementDate: "2023-12-25",
      totalFunding: 1250000,
      orderCount: 100,
      fundingRate: 130,
    },
    {
      id: 1002,
      fundingId: 1002,
      productName: "천연 모기 퇴치 스프레이",
      settlementDate: "2023-12-28",
      totalFunding: 880000,
      orderCount: 100,
      fundingRate: 110,
    },
    {
      id: 1003,
      fundingId: 1003,
      productName: "친환경 음식물 처리기",
      settlementDate: "2024-01-05",
      totalFunding: 5250000,
      orderCount: 100,
      fundingRate: 150,
    },
    {
      id: 1004,
      fundingId: 1004,
      productName: "유기농 면 티셔츠",
      settlementDate: "2023-12-30",
      totalFunding: 975000,
      orderCount: 100,
      fundingRate: 118,
    },
    {
      id: 1005,
      fundingId: 1005,
      productName: "재활용 소재 가방",
      settlementDate: "2024-01-10",
      totalFunding: 675000,
      orderCount: 100,
      fundingRate: 102,
    },
    {
      id: 1006,
      fundingId: 1006,
      productName: "태양광 충전기",
      settlementDate: "2024-01-15",
      totalFunding: 4500000,
      orderCount: 100,
      fundingRate: 150,
    },
    {
      id: 1007,
      fundingId: 1007,
      productName: "생분해성 수세미",
      settlementDate: "2024-01-20",
      totalFunding: 475000,
      orderCount: 100,
      fundingRate: 123,
    },
    {
      id: 1008,
      fundingId: 1008,
      productName: "에코 수저 세트",
      settlementDate: "2024-01-25",
      totalFunding: 350000,
      orderCount: 100,
      fundingRate: 123,
    },
    {
      id: 1009,
      fundingId: 1009,
      productName: "유기농 면 손수건",
      settlementDate: "2024-01-30",
      totalFunding: 225000,
      orderCount: 100,
      fundingRate: 123,
    },
    {
      id: 1010,
      fundingId: 1010,
      productName: "재활용 플라스틱 화분",
      settlementDate: "2024-02-05",
      totalFunding: 625000,
      orderCount: 100,
      fundingRate: 123,
    },
  ];

  // 더미 요약 정보
  const dummySummary: FundingReportSummary = {
    totalAmount: 15205000, // 총 펀딩액
    settlementAmount: 13684500, // 정산 예정 금액 (총 펀딩액의 90%)
  };

  return {
    dummyReports,
    dummySummary,
    getPaginatedDummyReports: (
      page: number,
      size: number = 5
    ): FundingReportsResponse => {
      const startIndex = page * size;
      const endIndex = startIndex + size;
      const paginatedItems = dummyReports.slice(startIndex, endIndex);

      return {
        content: paginatedItems,
        totalElements: dummyReports.length,
        totalPages: Math.ceil(dummyReports.length / size),
        currentPage: page,
        size: size,
        number: page,
        last: endIndex >= dummyReports.length,
        first: page === 0,
      };
    },
  };
};
