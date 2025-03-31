import React from "react";
import {
  PieChart,
  Pie,
  Cell,
  Tooltip,
  ResponsiveContainer,
  Legend,
  PieProps as RechartsPieProps,
  LegendProps as RechartsLegendProps,
} from "recharts";
import "../styles/dashboardComponents.css";

interface AgeGroupData {
  name: string;
  value: number;
  fill?: string; // 각 섹션 색상
}

// Recharts 컴포넌트의 Props 타입 확장
interface PieProps extends Partial<RechartsPieProps> {
  cx?: string | number;
  cy?: string | number;
  outerRadius?: number;
  innerRadius?: number;
  paddingAngle?: number;
}

interface LegendProps extends Partial<RechartsLegendProps> {
  layout?: "horizontal" | "vertical";
  verticalAlign?: "top" | "middle" | "bottom";
  align?: "left" | "center" | "right";
  iconType?: "circle" | "square" | "rect" | "diamond" | "cross" | "line";
}

interface AgeGroupChartProps {
  data: AgeGroupData[];
  pieProps?: Record<string, unknown>; // any 대신 Record 타입 사용
  legendProps?: Record<string, unknown>; // any 대신 Record 타입 사용
}

const AgeGroupChart: React.FC<AgeGroupChartProps> = ({
  data,
  pieProps,
  legendProps,
}) => {
  const hasData = data && data.length > 0;

  // 디폴트 Pie 속성
  const defaultPieProps: PieProps = {
    cx: "45%",
    cy: "50%",
    outerRadius: 110,
    innerRadius: 60,
    paddingAngle: 1,
  };

  // 디폴트 Legend 속성
  const defaultLegendProps: LegendProps = {
    layout: "vertical",
    verticalAlign: "middle",
    align: "right",
    iconType: "circle",
  };

  // props와 디폴트 속성 병합
  const mergedPieProps = { ...defaultPieProps, ...(pieProps || {}) };
  const mergedLegendProps = { ...defaultLegendProps, ...(legendProps || {}) };

  // 총 합계 계산과 퍼센트 계산
  const calculatePercentages = (inputData: AgeGroupData[]): AgeGroupData[] => {
    const total = inputData.reduce((sum, item) => sum + item.value, 0);

    return inputData.map((item) => {
      const percentage = parseFloat(((item.value / total) * 100).toFixed(1));
      // 이름에 퍼센트 값 추가
      return {
        ...item,
        name: `${item.name} ${percentage}%`,
      };
    });
  };

  const dataWithPercentages = hasData ? calculatePercentages(data) : [];

  return (
    <div className="card-common age-group-chart-card">
      {hasData ? (
        <div className="age-chart-container">
          <div className="chart-area">
            <ResponsiveContainer width="100%" height="100%">
              <PieChart>
                <Pie
                  data={dataWithPercentages}
                  cx={mergedPieProps.cx}
                  cy={mergedPieProps.cy}
                  labelLine={false}
                  label={false}
                  outerRadius={mergedPieProps.outerRadius}
                  innerRadius={mergedPieProps.innerRadius}
                  fill="#8884d8"
                  dataKey="value"
                  paddingAngle={mergedPieProps.paddingAngle}
                  nameKey="name"
                  isAnimationActive={false}
                >
                  {dataWithPercentages.map((entry, index) => (
                    <Cell
                      key={`cell-${index}`}
                      fill={entry.fill || "#cccccc"}
                    />
                  ))}
                </Pie>
                <Tooltip
                  formatter={(value: number) => `${value}명`}
                  isAnimationActive={false}
                />
                <Legend
                  layout={mergedLegendProps.layout}
                  verticalAlign={mergedLegendProps.verticalAlign}
                  align={mergedLegendProps.align}
                  iconType={mergedLegendProps.iconType}
                  formatter={(value) => {
                    // 퍼센트 부분과 레이블 부분 분리
                    const parts = value.split(" ");
                    const percent = parts.pop();
                    const label = parts.join(" ");
                    return (
                      <span className="recharts-legend-item-text">
                        <span>{label}</span>
                        <span className="chart-percent">{percent}</span>
                      </span>
                    );
                  }}
                />
              </PieChart>
            </ResponsiveContainer>
          </div>
        </div>
      ) : (
        <div className="no-data-message">연령대별 통계 데이터가 없습니다.</div>
      )}
    </div>
  );
};

export default AgeGroupChart;
