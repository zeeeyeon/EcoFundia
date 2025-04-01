import React, { useEffect, useState } from "react";
import { useSearchParams } from "react-router-dom";
import Sidebar from "../../../shared/components/Sidebar";
import useFundingReportsStore from "../stores/store";
import ReportsSummaryCard from "../components/ReportsSummaryCard";
import ReportsTable from "../components/ReportsTable";
import Pagination from "../../../shared/components/Pagination";
import "../styles/FundingReportsPage.css";
import "../../../shared/styles/common.css";

const FundingReportsPage: React.FC = () => {
  // 사이드바 상태
  const [isSidebarOpen, setIsSidebarOpen] = useState(true);
  const toggleSidebar = () => setIsSidebarOpen(!isSidebarOpen);

  // URL 파라미터 관리
  const [searchParams, setSearchParams] = useSearchParams();
  const currentPage = parseInt(searchParams.get("page") || "0", 10);

  // 스토어에서 상태 및 액션 가져오기
  const {
    reports,
    totalAmount,
    settlementAmount,
    totalPages,
    isLoading,
    error,
    fetchReports,
    resetError,
  } = useFundingReportsStore();

  // 페이지 변경 핸들러
  const handlePageChange = (page: number) => {
    setSearchParams({ page: page.toString() });
  };

  // 에러 닫기 핸들러
  const handleCloseError = () => {
    resetError();
  };

  // 페이지 로드 시 데이터 가져오기
  useEffect(() => {
    fetchReports(currentPage);
  }, [currentPage, fetchReports]);

  return (
    <div className="funding-reports-page">
      <Sidebar isOpen={isSidebarOpen} toggleSidebar={toggleSidebar} />

      <div className={`main-content ${isSidebarOpen ? "with-sidebar" : ""}`}>
        <h1 className="page-title">정산내역</h1>

        <div className="reports-content-wrapper">
          {/* 요약 정보 카드 */}
          <ReportsSummaryCard
            totalAmount={totalAmount}
            settlementAmount={settlementAmount}
            isLoading={isLoading}
          />

          {/* 테이블 제목 */}
          <h2 className="reports-table-title">내 펀딩 리스트 정산내역</h2>

          {/* 정산내역 테이블 */}
          <ReportsTable reports={reports} isLoading={isLoading} />

          {/* 페이지네이션 */}
          {!isLoading && totalPages > 0 && (
            <Pagination
              currentPage={currentPage}
              totalPages={totalPages}
              onPageChange={handlePageChange}
            />
          )}
        </div>
      </div>

      {/* 에러 메시지 (오버레이 형태) */}
      {error && (
        <div className="global-error-container">
          <div className="global-error-message">
            <h3>오류 발생</h3>
            <p>{error}</p>
            <button className="global-error-close" onClick={handleCloseError}>
              확인
            </button>
          </div>
        </div>
      )}
    </div>
  );
};

export default FundingReportsPage;
