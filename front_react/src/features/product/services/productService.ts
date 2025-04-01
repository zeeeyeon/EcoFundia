import client from "../../../shared/api/client";

// 상품 상세 정보 API 응답 타입
export interface ProductDetailContent {
  fundingId: number;
  title: string;
  description: string;
  imageUrl: string;
  progressPercentage: number;
}

// 연령대별 통계 API 응답 타입
export interface AgeGroupItem {
  generation: number; // 10, 20, 30, 40, 50, 60 등
  ratio: number; // 비율 (백분율)
}

// 최근 결제 내역 API 응답 타입
export interface OrderItem {
  orderId: number;
  nickname: string;
  createdAt: string;
  totalPrice: number;
  quantity: number;
}

// API 응답 공통 타입
export interface ApiResponse<T> {
  status: {
    code: number;
    message: string;
  };
  content: T;
}

// API 경로
const API_PATHS = {
  PRODUCT_DETAIL: (fundingId: number) => `/seller/funding/detail/${fundingId}`,
  PRODUCT_STATISTICS: (fundingId: number) =>
    `/seller/funding/detail/statistics/${fundingId}`,
  PRODUCT_ORDERS: (fundingId: number, page: number = 0) =>
    `/seller/funding/detail/order/${fundingId}?page=${page}`,
};

/**
 * 상품 상세 정보를 가져오는 함수
 * @param fundingId 조회할 펀딩 상품 ID
 */
export const getProductDetails = async (
  fundingId: number
): Promise<ProductDetailContent> => {
  try {
    const response = await client.get<ApiResponse<ProductDetailContent>>(
      API_PATHS.PRODUCT_DETAIL(fundingId)
    );
    return response.data.content;
  } catch (error) {
    console.error(`Error fetching product details (ID: ${fundingId}):`, error);
    throw new Error("상품 상세 정보를 불러오는데 실패했습니다.");
  }
};

/**
 * 상품의 연령대별 통계를 가져오는 함수
 * @param fundingId 조회할 펀딩 상품 ID
 */
export const getProductStatistics = async (
  fundingId: number
): Promise<AgeGroupItem[]> => {
  try {
    const response = await client.get<ApiResponse<AgeGroupItem[]>>(
      API_PATHS.PRODUCT_STATISTICS(fundingId)
    );
    return response.data.content;
  } catch (error) {
    console.error(
      `Error fetching product statistics (ID: ${fundingId}):`,
      error
    );
    throw new Error("상품 통계 정보를 불러오는데 실패했습니다.");
  }
};

/**
 * 상품의 최근 결제 내역을 가져오는 함수
 * @param fundingId 조회할 펀딩 상품 ID
 * @param page 페이지 번호 (0부터 시작)
 */
export const getProductOrders = async (
  fundingId: number,
  page: number = 0
): Promise<OrderItem[]> => {
  try {
    const response = await client.get<ApiResponse<OrderItem[]>>(
      API_PATHS.PRODUCT_ORDERS(fundingId, page)
    );
    return response.data.content;
  } catch (error) {
    console.error(
      `Error fetching product orders (ID: ${fundingId}, page: ${page}):`,
      error
    );
    throw new Error("결제 내역을 불러오는데 실패했습니다.");
  }
};
