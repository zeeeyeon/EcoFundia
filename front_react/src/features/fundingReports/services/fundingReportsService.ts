import client from "../../../shared/api/client";
import {
  ApiResponse,
  // 정산 완료된 펀딩 목록 응답 타입 (페이징 포함 가정)
  CompletedFundingReportsResponse,
  // 정산 예정 금액 응답 content 타입 (PDF 기반 추정)
  ScheduledAmountResponseContent,
  // 총 펀딩액 응답 content 타입 (새 명세서 기반)
  TotalAmountResponseContent,
} from "../types"; // 실제 타입 정의는 이 파일에서 이루어져야 합니다.

// API 경로 (제공된 명세서 기반으로 수정 및 추가)
const API_PATHS = {
  COMPLETED_FUNDINGS: "/seller/settlements/completed-fundings", // 정산된 프로젝트 목록
  SCHEDULED_AMOUNT: "/seller/settlements/expected-fundings", // 정산 예정 금액
  TOTAL_AMOUNT: "/seller/total-amount", // 총 펀딩액 (추가)
};

/**
 * 정산 완료된 펀딩 목록 조회
 * @param page 페이지 번호 (0부터 시작)
 * @returns Promise<CompletedFundingReportsResponse>
 */
export const getCompletedFundingReports = async (
  page: number
): Promise<CompletedFundingReportsResponse> => {
  try {
    const response = await client.get<
      ApiResponse<CompletedFundingReportsResponse>
    >(`${API_PATHS.COMPLETED_FUNDINGS}?page=${page}&size=5`);

    // content가 null이면 빈 데이터로 처리
    if (!response.data.content) {
      return {
        content: [],
        totalElements: 0,
        totalPages: 0,
        currentPage: page,
        size: 5,
        number: page,
        last: true,
        first: true,
      };
    }

    return response.data.content;
  } catch (error: unknown) {
    console.error("정산 완료된 펀딩 목록 조회 중 오류 발생:", error);
    if (
      error &&
      typeof error === "object" &&
      "response" in error &&
      error.response &&
      typeof error.response === "object" &&
      "status" in error.response
    ) {
      const status = error.response.status as number;
      if (status === 401 || status === 403)
        throw new Error("인증 정보가 유효하지 않습니다. 다시 로그인해주세요.");
      if (status === 404)
        throw new Error("정산 완료된 펀딩 목록 정보를 찾을 수 없습니다.");
      if (status >= 500)
        throw new Error("서버 오류가 발생했습니다. 잠시 후 다시 시도해주세요.");
    }
    throw new Error(
      "정산 완료된 펀딩 목록을 불러오는데 실패했습니다. 네트워크 연결을 확인해주세요."
    );
  }
};

/**
 * 정산 예정 금액 조회
 * @returns Promise<number> 정산 예정 금액
 */
export const getScheduledAmount = async (): Promise<number> => {
  try {
    console.log("정산 예정 금액 API 요청:", API_PATHS.SCHEDULED_AMOUNT);
    const response = await client.get<
      ApiResponse<ScheduledAmountResponseContent>
    >(API_PATHS.SCHEDULED_AMOUNT);

    console.log("정산 예정 금액 API 응답:", response.data);

    // 응답 구조 확인
    if (!response.data) {
      console.warn("API 응답이 비어있습니다.");
      return 0;
    }

    // status 확인
    if (!response.data.status || response.data.status.code !== 200) {
      console.warn("API 응답 상태가 정상이 아닙니다:", response.data.status);
      return 0;
    }

    // content 확인
    if (!response.data.content) {
      console.warn("API 응답에 content가 없습니다:", response.data);
      return 0;
    }

    // expectedAmount 확인
    if (typeof response.data.content.expectedAmount !== "number") {
      console.warn(
        "API 응답의 expectedAmount가 숫자가 아닙니다:",
        response.data.content
      );
      return 0;
    }

    console.log(
      "정상적인 정산 예정 금액:",
      response.data.content.expectedAmount
    );
    return response.data.content.expectedAmount;
  } catch (error: unknown) {
    console.error("정산 예정 금액 조회 중 오류 발생:", error);

    // 에러 처리 (404 등의 상황에서도 0 반환)
    return 0;
  }
};

/**
 * 판매자의 총 펀딩액 조회 (추가된 함수)
 * @returns Promise<number> 총 펀딩액
 */
export const getTotalFundingAmount = async (): Promise<number> => {
  try {
    console.log("총 펀딩액 API 요청:", API_PATHS.TOTAL_AMOUNT);
    const response = await client.get<ApiResponse<TotalAmountResponseContent>>(
      API_PATHS.TOTAL_AMOUNT
    );

    console.log("총 펀딩액 API 응답:", response.data);

    // 응답 구조 확인
    if (!response.data) {
      console.warn("API 응답이 비어있습니다.");
      return 0;
    }

    // status 확인
    if (!response.data.status || response.data.status.code !== 200) {
      console.warn("API 응답 상태가 정상이 아닙니다:", response.data.status);
      return 0;
    }

    // content 확인
    if (!response.data.content) {
      console.warn("API 응답에 content가 없습니다:", response.data);
      return 0;
    }

    // totalAmount 확인
    if (typeof response.data.content.totalAmount !== "number") {
      console.warn(
        "API 응답의 totalAmount가 숫자가 아닙니다:",
        response.data.content
      );
      return 0;
    }

    console.log("정상적인 총 펀딩액:", response.data.content.totalAmount);
    return response.data.content.totalAmount;
  } catch (error: unknown) {
    console.error("총 펀딩액 조회 중 오류 발생:", error);

    // 에러 처리 (404 등의 상황에서도 0 반환)
    return 0;
  }
};
