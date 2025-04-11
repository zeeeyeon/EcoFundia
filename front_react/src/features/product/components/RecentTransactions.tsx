import React, { useState, useEffect } from "react";
import "../styles/recentTransactions.css";
import "../../../shared/styles/common.css";
import { OrderItem, getProductOrders } from "../services/productService";
import { FaUser } from "react-icons/fa";
import { FiChevronLeft, FiChevronRight } from "react-icons/fi";
import { LoadingSpinner } from "../../../shared";

interface RecentTransactionsProps {
  fundingId: number;
}

const RecentTransactions: React.FC<RecentTransactionsProps> = ({
  fundingId,
}) => {
  // 페이지 상태 관리
  const [currentPage, setCurrentPage] = useState(0); // API 페이지는 0부터 시작
  const [orders, setOrders] = useState<OrderItem[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [hasMore, setHasMore] = useState(true);

  // 에러 초기화 함수 추가
  const resetError = () => {
    setError(null);
  };

  // 데이터 로딩
  useEffect(() => {
    if (!fundingId) return;

    const fetchOrders = async () => {
      setLoading(true);
      setError(null);

      try {
        const data = await getProductOrders(fundingId, currentPage);
        setOrders(data);

        // 데이터가 비어있거나 5개 미만이면 더 이상 데이터가 없는 것으로 판단
        setHasMore(data.length >= 5);
      } catch (err) {
        console.error("Error fetching orders:", err);
        setError("결제 내역을 불러오는데 실패했습니다.");
      } finally {
        setLoading(false);
      }
    };

    fetchOrders();
  }, [fundingId, currentPage]);

  const handlePrevPage = () => {
    if (currentPage > 0) {
      setCurrentPage((prev) => prev - 1);
    }
  };

  const handleNextPage = () => {
    if (hasMore) {
      setCurrentPage((prev) => prev + 1);
    }
  };

  // 날짜 포맷팅 함수
  const formatDate = (dateStr: string): string => {
    const date = new Date(dateStr);
    const months = [
      "Jan",
      "Feb",
      "Mar",
      "Apr",
      "May",
      "Jun",
      "Jul",
      "Aug",
      "Sep",
      "Oct",
      "Nov",
      "Dec",
    ];
    return `${
      months[date.getMonth()]
    } ${date.getDate()}, ${date.getFullYear()}`;
  };

  // 금액 포맷팅 함수
  const formatAmount = (amount: number): string => {
    return new Intl.NumberFormat("ko-KR", {
      style: "currency",
      currency: "KRW",
      maximumFractionDigits: 0,
    }).format(amount);
  };

  return (
    <div className="recent-transactions-section">
      <div className="section-title-wrapper">
        <h3 className="section-title">최근 결제 내역</h3>
        {orders.length > 0 && !loading && !error && (
          <div className="pagination-controls">
            <button onClick={handlePrevPage} disabled={currentPage === 0}>
              <FiChevronLeft />
            </button>
            <button onClick={handleNextPage} disabled={!hasMore}>
              <FiChevronRight />
            </button>
          </div>
        )}
      </div>

      {loading && (
        <div className="spinner-wrapper">
          <LoadingSpinner message="결제 내역을 불러오는 중..." />
        </div>
      )}

      {error && (
        <div className="global-error-container">
          <div className="global-error-message">
            <h3>결제 내역 오류</h3>
            <p>{error}</p>
            <button className="global-error-close" onClick={resetError}>
              확인
            </button>
          </div>
        </div>
      )}

      {!loading && !error && (
        <div className="table-container">
          <table className="transactions-table">
            <thead>
              <tr>
                <th>유저 닉네임</th>
                <th>날짜</th>
                <th>수량</th>
                <th className="amount-header">펀딩금액</th>
              </tr>
            </thead>

            <tbody>
              {orders.length > 0 ? (
                orders.map((order) => (
                  <tr key={order.orderId}>
                    <td>
                      <div
                        style={{
                          display: "flex",
                          alignItems: "center",
                          gap: "8px",
                        }}
                      >
                        <div
                          style={{
                            backgroundColor: "#E6F1FD",
                            width: "32px",
                            height: "32px",
                            borderRadius: "50%",
                            display: "flex",
                            alignItems: "center",
                            justifyContent: "center",
                          }}
                        >
                          <FaUser size={14} color="#000" />
                        </div>
                        {order.nickname}
                      </div>
                    </td>
                    <td>{formatDate(order.createdAt)}</td>
                    <td>{order.quantity}</td>
                    <td className="amount">{formatAmount(order.totalPrice)}</td>
                  </tr>
                ))
              ) : (
                <tr className="no-data-row">
                  <td
                    colSpan={4}
                    className="no-data-message"
                    style={{ textAlign: "center", padding: "50px 0" }}
                  >
                    결제 내역이 없습니다.
                  </td>
                </tr>
              )}
            </tbody>
          </table>
        </div>
      )}
    </div>
  );
};

export default RecentTransactions;
