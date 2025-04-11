import React from "react";
import "./Pagination.css";

interface PaginationProps {
  currentPage: number;
  totalPages: number;
  onPageChange: (page: number) => void;
}

const Pagination: React.FC<PaginationProps> = ({
  currentPage,
  totalPages,
  onPageChange,
}) => {
  // 페이지 범위 계산 (최대 5개 페이지 표시)
  const getPageRange = () => {
    const range = [];
    const maxVisiblePages = 5;
    let startPage = Math.max(0, currentPage - Math.floor(maxVisiblePages / 2));
    const endPage = Math.min(totalPages - 1, startPage + maxVisiblePages - 1);

    // 5개 미만의 페이지가 표시될 경우 시작 페이지 조정
    if (endPage - startPage + 1 < maxVisiblePages) {
      startPage = Math.max(0, endPage - maxVisiblePages + 1);
    }

    for (let i = startPage; i <= endPage; i++) {
      range.push(i);
    }

    return range;
  };

  return (
    <nav className="pagination-container">
      <ul className="pagination">
        {/* 첫 페이지로 */}
        <li
          className={`pagination-item ${currentPage === 0 ? "disabled" : ""}`}
        >
          <button
            onClick={() => onPageChange(0)}
            disabled={currentPage === 0}
            aria-label="첫 페이지로"
          >
            &laquo;
          </button>
        </li>

        {/* 이전 페이지로 */}
        <li
          className={`pagination-item ${currentPage === 0 ? "disabled" : ""}`}
        >
          <button
            onClick={() => onPageChange(currentPage - 1)}
            disabled={currentPage === 0}
            aria-label="이전 페이지로"
          >
            &lsaquo;
          </button>
        </li>

        {/* 페이지 번호 */}
        {getPageRange().map((page) => (
          <li
            key={page}
            className={`pagination-item ${
              page === currentPage ? "active" : ""
            }`}
          >
            <button onClick={() => onPageChange(page)}>{page + 1}</button>
          </li>
        ))}

        {/* 다음 페이지로 */}
        <li
          className={`pagination-item ${
            currentPage === totalPages - 1 ? "disabled" : ""
          }`}
        >
          <button
            onClick={() => onPageChange(currentPage + 1)}
            disabled={currentPage === totalPages - 1}
            aria-label="다음 페이지로"
          >
            &rsaquo;
          </button>
        </li>

        {/* 마지막 페이지로 */}
        <li
          className={`pagination-item ${
            currentPage === totalPages - 1 ? "disabled" : ""
          }`}
        >
          <button
            onClick={() => onPageChange(totalPages - 1)}
            disabled={currentPage === totalPages - 1}
            aria-label="마지막 페이지로"
          >
            &raquo;
          </button>
        </li>
      </ul>
    </nav>
  );
};

export default Pagination;
