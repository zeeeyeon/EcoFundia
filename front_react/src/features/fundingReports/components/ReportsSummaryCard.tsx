import React from "react";
import "../styles/ReportsSummaryCard.css";

interface ReportsSummaryCardProps {
  totalAmount: number;
  settlementAmount: number;
  isLoading: boolean;
}

const ReportsSummaryCard: React.FC<ReportsSummaryCardProps> = ({
  totalAmount,
  settlementAmount,
  isLoading: isLoadingSummary,
}) => {
  // 금액 포맷팅 함수
  const formatCurrency = (amount: number) => {
    return new Intl.NumberFormat("ko-KR", {
      style: "currency",
      currency: "KRW",
      maximumFractionDigits: 0,
    }).format(amount);
  };

  if (isLoadingSummary) {
    return (
      <div className="reports-summary-card loading">
        <div className="summary-item skeleton"></div>
        <div className="summary-item skeleton"></div>
      </div>
    );
  }

  return (
    <div className="reports-summary-card">
      <div className="summary-item total-funding">
        <div className="icon-wrapper total-icon">
          <div className="icon-bg">
            <i className="icon-chart"></i>
          </div>
        </div>
        <div className="summary-content">
          <h3>총 펀딩 금액</h3>
          <div className="amount total-amount">
            {formatCurrency(totalAmount)}
          </div>
        </div>
      </div>

      <div className="summary-item settlement">
        <div className="icon-wrapper settlement-icon">
          <div className="icon-bg">
            <i className="icon-wallet"></i>
          </div>
        </div>
        <div className="summary-content">
          <h3>정산 예정 금액</h3>
          <div className="amount settlement-amount">
            {formatCurrency(settlementAmount)}
          </div>
        </div>
      </div>
    </div>
  );
};

export default ReportsSummaryCard;
