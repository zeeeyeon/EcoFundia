import React from "react";
import { getDummyTransactions, Transaction } from "../services/productService";
import { FaUser } from "react-icons/fa";
import { FiChevronLeft, FiChevronRight } from "react-icons/fi";

const ITEMS_PER_PAGE = 5; // 페이지당 항목 수

// 더미 데이터를 미리 가져오기
const dummyTransactions = getDummyTransactions();

const RecentTransactions: React.FC = () => {
  // 페이지 상태 관리
  const [currentPage, setCurrentPage] = React.useState(1);
  const [allTransactions] = React.useState<Transaction[]>(dummyTransactions);

  // 페이지 계산
  const totalItems = allTransactions.length;
  const startIndex = (currentPage - 1) * ITEMS_PER_PAGE;
  const endIndex = startIndex + ITEMS_PER_PAGE;
  const transactionsToShow = allTransactions.slice(startIndex, endIndex);

  // 현재 페이지가 마지막 데이터셋을 포함하는지 여부
  const isLastDataSet = endIndex >= totalItems;

  const handlePrevPage = () => {
    if (currentPage > 1) {
      setCurrentPage((prev) => prev - 1);
    }
  };

  const handleNextPage = () => {
    if (!isLastDataSet) {
      setCurrentPage((prev) => prev + 1);
    }
  };

  // 금액 포맷팅 함수 (단위 포함)
  const formatAmount = (amount: number): string => {
    // 원화를 달러로 변환한 금액 (약 1/1300 환율 적용)
    const dollarAmount = amount / 1300;
    return `$${dollarAmount.toFixed(2)}`;
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

  return (
    <div className="recent-transactions-section">
      <div className="section-title-wrapper">
        <h3 className="section-title">최근 결제 내역</h3>
        {totalItems > 0 && (
          <div className="pagination-controls">
            <button onClick={handlePrevPage} disabled={currentPage === 1}>
              <FiChevronLeft />
            </button>
            <button onClick={handleNextPage} disabled={isLastDataSet}>
              <FiChevronRight />
            </button>
          </div>
        )}
      </div>

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
            {transactionsToShow.map((transaction) => (
              <tr key={transaction.id}>
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
                        backgroundColor:
                          transaction.id % 2 === 0 ? "#E6F1FD" : "#EDEEFC",
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
                    {transaction.nickname}
                  </div>
                </td>
                <td>{formatDate(transaction.date)}</td>
                <td>{transaction.quantity}</td>
                <td className="amount">{formatAmount(transaction.amount)}</td>
              </tr>
            ))}
            {/* 데이터가 없을 때 메시지 */}
            {transactionsToShow.length === 0 && totalItems === 0 && (
              <tr>
                <td colSpan={4} className="no-data-message">
                  결제 내역이 없습니다.
                </td>
              </tr>
            )}
          </tbody>
        </table>
      </div>
    </div>
  );
};

export default RecentTransactions;
