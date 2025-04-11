import React, { useState, useEffect } from "react";
import "../styles/statisticsChart.css";
import "../../../shared/styles/common.css";
import AgeGroupChart from "../../dashboard/components/AgeGroupChart";
import { getProductStatistics } from "../services/productService";
import { LoadingSpinner } from "../../../shared";

// 연령대별 색상 맵핑
const AGE_GROUP_COLORS = {
  10: "#A8DADC", // 밝은 하늘색 계열
  20: "#457B9D", // 진한 파란색 계열 (서브 컬러)
  30: "#F4A261", // 주황색 계열 (포인트)
  40: "#E76F51", // 붉은 주황색 계열
  50: "#2A9D8F", // 청록색 계열
  60: "#9E2A2B", // 짙은 적색
  other: "#cccccc", // 기타 - 회색
};

interface ChartData {
  name: string;
  value: number;
  fill?: string;
}

interface StatisticsChartProps {
  fundingId: number;
}

// 제품 모달용 커스텀 스타일을 적용한 AgeGroupChart
const ProductModalChartWrapper: React.FC<{ data: ChartData[] }> = ({
  data,
}) => {
  // AgeGroupChart에 전달될 스타일 props 준비
  const chartProps = {
    data,
    // 레이아웃 및 위치 조정을 위한 속성 오버라이드
    pieProps: {
      cx: "50%", // 도넛 차트 X축 위치 조정
      cy: "50%", // 도넛 차트 Y축 위치 유지
      outerRadius: 120, // 도넛 크기 조정
      innerRadius: 60, // 내부 홀 크기 조정
      paddingAngle: 2, // 섹션 간 간격
    },
    legendProps: {
      align: "right",
      verticalAlign: "middle",
      layout: "vertical",
      iconType: "circle",
    },
  };

  return (
    <div
      className="chart-wrapper"
      style={{ width: "100%", height: "100%", position: "relative" }}
    >
      <AgeGroupChart {...chartProps} />
    </div>
  );
};

const StatisticsChart: React.FC<StatisticsChartProps> = ({ fundingId }) => {
  const [chartData, setChartData] = useState<ChartData[]>([]);
  const [loading, setLoading] = useState<boolean>(true);
  const [error, setError] = useState<string | null>(null);

  // 에러 초기화 함수 추가
  const resetError = () => {
    setError(null);
  };

  useEffect(() => {
    const fetchStatistics = async () => {
      if (!fundingId) return;

      setLoading(true);
      try {
        const data = await getProductStatistics(fundingId);

        // API 응답을 차트 데이터 형식으로 변환
        const formattedData: ChartData[] = data.map((item) => ({
          name: `${item.generation}대`,
          value: item.ratio,
          fill:
            AGE_GROUP_COLORS[
              item.generation as keyof typeof AGE_GROUP_COLORS
            ] || AGE_GROUP_COLORS.other,
        }));

        setChartData(formattedData);
      } catch (error) {
        console.error("Error fetching age statistics:", error);
        setError("연령대별 통계를 불러오는데 실패했습니다.");
      } finally {
        setLoading(false);
      }
    };

    fetchStatistics();
  }, [fundingId]);

  return (
    <div className="statistics-chart-section">
      <div className="section-header">
        <h3 className="section-title">연령대별 통계</h3>
      </div>

      {loading && (
        <div className="spinner-wrapper">
          <LoadingSpinner message="통계 데이터를 불러오는 중..." />
        </div>
      )}

      {error && (
        <div className="global-error-container">
          <div className="global-error-message">
            <h3>통계 데이터 오류</h3>
            <p>{error}</p>
            <button className="global-error-close" onClick={resetError}>
              확인
            </button>
          </div>
        </div>
      )}

      {!loading && !error && (
        <div className="chart-container">
          {chartData.length > 0 ? (
            <ProductModalChartWrapper data={chartData} />
          ) : (
            <div className="no-data-message">
              <p>통계 데이터가 없습니다.</p>
            </div>
          )}
        </div>
      )}
    </div>
  );
};

export default StatisticsChart;
