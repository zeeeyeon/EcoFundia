import client from '../../../shared/api/client'; // 공유 클라이언트 import
// Axios 타입 import 불필요

// API 함수 타입 정의 (예시)
interface DashboardData {
    stats: { totalFunding: number; ongoingProducts: number; todayOrders: number };
    usageData: { name: string; value: number }[];
    fundingData: { name: string; value: number }[];
    products: { id: string; name: string; status: string; progress: number; endDate: string }[];
}

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

const dashboardService = {
    getDashboardData,
    // 다른 대시보드 관련 API 함수들 추가...
};

export default dashboardService; 