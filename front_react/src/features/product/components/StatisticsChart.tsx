import React from 'react';
import AgeGroupChart from '../../dashboard/components/AgeGroupChart';

// 연령대별 더미 데이터 (프로젝트 컨셉 색상 적용)
const dummyAgeGroupData = [
    { name: '10대', value: 15, fill: '#A8DADC' }, // 밝은 하늘색 계열
    { name: '20대', value: 35, fill: '#457B9D' }, // 진한 파란색 계열 (서브 컬러)
    { name: '30대', value: 25, fill: '#F4A261' }, // 주황색 계열 (포인트)
    { name: '40대', value: 15, fill: '#E76F51' }, // 붉은 주황색 계열
    { name: '50대 이상', value: 10, fill: '#2A9D8F' }, // 청록색 계열
];

interface ChartData {
    name: string;
    value: number;
    fill?: string;
}

// 제품 모달용 커스텀 스타일을 적용한 AgeGroupChart
const ProductModalChartWrapper: React.FC<{ data: ChartData[] }> = ({ data }) => {
    // AgeGroupChart에 전달될 스타일 props 준비
    const chartProps = {
        data,
        // 레이아웃 및 위치 조정을 위한 속성 오버라이드
        pieProps: {
            cx: "38%", // 도넛 차트 X축 위치 조정
            cy: "50%",  // 도넛 차트 Y축 위치 유지
            outerRadius: 130, // 도넛 크기 조정
            innerRadius: 70,   // 내부 홀 크기 조정
            // 애니메이션 활성화 (기본값으로 되돌림)
        },
        legendProps: {
            align: "right",
            verticalAlign: "middle",
            layout: "vertical",
            iconType: "circle"
        }
    };

    return <AgeGroupChart {...chartProps} />;
};

const StatisticsChart: React.FC = () => {
    // 차트 데이터 직접 사용
    const chartData = dummyAgeGroupData;

    return (
        <div className="statistics-chart-section">
            <div className="section-title-wrapper">
                <h3 className="section-title">연령대별 통계</h3>
            </div>
            <ProductModalChartWrapper data={chartData} />
        </div>
    );
};

export default StatisticsChart; 