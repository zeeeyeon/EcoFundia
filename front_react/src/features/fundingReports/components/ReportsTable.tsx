import React from "react";
import { FundingReport } from "../types";
import "../styles/ReportsTable.css";

interface ReportsTableProps {
  reports: FundingReport[];
  isLoading: boolean;
}

const ReportsTable: React.FC<ReportsTableProps> = ({ reports, isLoading }) => {
  // 금액 포맷팅 함수
  const formatCurrency = (amount: number) => {
    return new Intl.NumberFormat("ko-KR", {
      style: "currency",
      currency: "KRW",
      maximumFractionDigits: 0,
    }).format(amount);
  };

  // 날짜 포맷팅 함수
  const formatDate = (dateString: string) => {
    const date = new Date(dateString);
    return date.toLocaleDateString("ko-KR", {
      year: "numeric",
      month: "long",
      day: "numeric",
    });
  };

  // 펀딩률 포맷팅 함수
  const formatFundingRate = (rate: number) => {
    return `+${rate}%`;
  };

  // 로딩 중일 때 스켈레톤 UI 표시
  if (isLoading) {
    return (
      <div className="reports-table-container">
        <table className="reports-table loading">
          <thead>
            <tr>
              <th>펀딩 상품</th>
              <th>마감일</th>
              <th>총 펀딩액</th>
              <th>주문 수</th>
              <th>달성률</th>
            </tr>
          </thead>
          <tbody>
            {Array(5)
              .fill(0)
              .map((_, index) => (
                <tr key={`skeleton-${index}`} className="skeleton-row">
                  <td>
                    <div className="skeleton"></div>
                  </td>
                  <td>
                    <div className="skeleton"></div>
                  </td>
                  <td>
                    <div className="skeleton"></div>
                  </td>
                  <td>
                    <div className="skeleton"></div>
                  </td>
                  <td>
                    <div className="skeleton"></div>
                  </td>
                </tr>
              ))}
          </tbody>
        </table>
      </div>
    );
  }

  // 데이터가 없을 때 표시
  if (reports.length === 0) {
    return (
      <div className="reports-table-container">
        <table className="reports-table empty">
          <thead>
            <tr>
              <th>펀딩 상품</th>
              <th>마감일</th>
              <th>총 펀딩액</th>
              <th>주문 수</th>
              <th>달성률</th>
            </tr>
          </thead>
          <tbody>
            <tr>
              <td colSpan={5} className="no-data-message">
                정산 내역이 없습니다.
              </td>
            </tr>
          </tbody>
        </table>
      </div>
    );
  }

  // 정산내역 테이블 표시
  return (
    <div className="reports-table-container">
      <table className="reports-table">
        <thead>
          <tr>
            <th>펀딩 상품</th>
            <th>마감일</th>
            <th>주문수</th>
            <th>총 펀딩액</th>
            <th>달성률</th>
          </tr>
        </thead>
        <tbody>
          {reports.map((report) => (
            <tr key={report.id}>
              <td className="product-name">{report.productName}</td>
              <td>{formatDate(report.settlementDate)}</td>
              <td className="order-count">{report.orderCount}</td>
              <td className="amount-column">
                {formatCurrency(report.totalFunding)}
              </td>

              <td className="funding-rate">
                <span className="rate-value">
                  {formatFundingRate(report.fundingRate)}
                </span>
              </td>
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  );
};

export default ReportsTable;
