import React from "react";
import "../styles/StatCard.css";

interface StatCardProps {
  title: string;
  value: string | number;
  unit?: string;
  icon?: React.ReactNode; // icon prop 추가 (optional ReactNode)
}

const StatCard: React.FC<StatCardProps> = ({ title, value, unit, icon }) => {
  return (
    <div className="stat-card">
      {/* 아이콘 렌더링 추가 */}
      {icon && <div className="stat-card-icon">{icon}</div>}
      <div className="stat-card-content">
        <h3 className="stat-card-title">{title}</h3>
        <p className="stat-card-value">
          {typeof value === "number" ? value.toLocaleString() : value}
          {unit && <span className="stat-card-unit"> {unit}</span>}{" "}
          {/* 단위 앞에 공백 추가 */}
        </p>
      </div>
    </div>
  );
};

export default StatCard;
