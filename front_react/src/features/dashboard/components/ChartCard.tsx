import React from 'react';
import '../styles/dashboardComponents.css';

interface ChartCardProps {
    title: string;
    children: React.ReactNode; // 차트 컴포넌트를 자식으로 받음
}

const ChartCard: React.FC<ChartCardProps> = ({ title, children }) => {
    return (
        <div className="chart-card">
            <h3 className="chart-card-title">{title}</h3>
            <div className="chart-content-wrapper">
                {children}
            </div>
        </div>
    );
};

export default ChartCard; 