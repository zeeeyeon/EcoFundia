import client from '../../../shared/api/client';

// API 응답 타입
export interface ProductDetailContent {
    fundingId: number;
    title: string;
    description: string;
    imageUrl: string;
    progressPercentage: number;
    // 추가 필드는 필요에 따라 확장
}

export interface ApiResponse<T> {
    status: {
        code: number;
        message: string;
    };
    content: T;
}

// 최근 거래 내역 타입
export interface Transaction {
    id: number;
    nickname: string;
    date: string;
    quantity: number;
    amount: number;
}

// API 경로
const API_PATHS = {
    PRODUCT_DETAIL: (fundingId: number) => `/seller/funding/detail/${fundingId}`,
};

/**
 * 상품 상세 정보를 가져오는 함수
 * @param fundingId 조회할 펀딩 상품 ID
 */
export const getProductDetails = async (fundingId: number): Promise<ProductDetailContent> => {
    try {
        const response = await client.get<ApiResponse<ProductDetailContent>>(
            API_PATHS.PRODUCT_DETAIL(fundingId)
        );
        return response.data.content;
    } catch (error) {
        console.error(`Error fetching product details (ID: ${fundingId}):`, error);
        throw new Error('상품 상세 정보를 불러오는데 실패했습니다.');
    }
};

/**
 * 더미 거래 내역 데이터 (API 미구현)
 */
export const getDummyTransactions = (): Transaction[] => {
    // 한국식 이름으로 구성된 더미 데이터 생성
    const koreanNames = ['도경원', '김한민', '도경록', '박수민', '송동현', '이지민', '정태양', '한지수', '오민준', '최서진'];

    const transactions: Transaction[] = [];
    for (let i = 1; i <= 17; i++) {
        transactions.push({
            id: i,
            nickname: koreanNames[i % koreanNames.length],
            date: `2025-${String(Math.floor(Math.random() * 12) + 1).padStart(2, '0')}-${String(Math.floor(Math.random() * 28) + 1).padStart(2, '0')}`,
            quantity: Math.floor(Math.random() * 12) + 1, // 1~12개 랜덤 수량
            amount: (Math.floor(Math.random() * 50) + 40) * 10000 // 400,000 ~ 900,000원 랜덤 금액
        });
    }
    return transactions;
}; 