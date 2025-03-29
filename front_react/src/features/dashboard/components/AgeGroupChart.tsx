import React from 'react';
import { PieChart, Pie, Cell, Tooltip, ResponsiveContainer, Legend, PieLabelRenderProps } from 'recharts';

interface AgeGroupData {
    name: string;
    value: number;
    fill?: string; // 각 섹션 색상
}

interface AgeGroupChartProps {
    data: AgeGroupData[];
}

const RADIAN = Math.PI / 180;
const renderCustomizedLabel = ({ cx, cy, midAngle, innerRadius, outerRadius, percent }: PieLabelRenderProps) => {
    if (typeof cx !== 'number' || typeof cy !== 'number' ||
        typeof midAngle !== 'number' || typeof innerRadius !== 'number' ||
        typeof outerRadius !== 'number' || typeof percent !== 'number') {
        return null;
    }

    const radius = innerRadius + (outerRadius - innerRadius) * 0.5;
    const x = cx + radius * Math.cos(-midAngle * RADIAN);
    const y = cy + radius * Math.sin(-midAngle * RADIAN);

    if ((percent * 100) < 5) return null;

    return (
        <text x={x} y={y} fill="white" textAnchor={x > cx ? 'start' : 'end'} dominantBaseline="central" fontSize="12px">
            {`${(percent * 100).toFixed(0)}%`}
        </text>
    );
};

const AgeGroupChart: React.FC<AgeGroupChartProps> = ({ data }) => {
    const hasData = data && data.length > 0;

    return (
        <div className="card-common age-group-chart-card">
            {hasData ? (
                <div className="age-chart-container">
                    <div className="chart-area">
                        <ResponsiveContainer width="100%" height="100%">
                            <PieChart>
                                <Pie
                                    data={data}
                                    cx="50%"
                                    cy="50%"
                                    labelLine={false}
                                    label={renderCustomizedLabel}
                                    outerRadius={110}
                                    innerRadius={60}
                                    fill="#8884d8"
                                    dataKey="value"
                                    paddingAngle={1}
                                >
                                    {data.map((entry, index) => (
                                        <Cell key={`cell-${index}`} fill={entry.fill || '#cccccc'} />
                                    ))}
                                </Pie>
                                <Tooltip formatter={(value: number) => `${value}명`} />
                                <Legend layout="vertical" verticalAlign="middle" align="right" iconType="circle" />
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