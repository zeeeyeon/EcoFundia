import React, { useEffect, useState } from "react";
import { useSearchParams } from "react-router-dom";
import Sidebar from "../../../shared/components/Sidebar";
import Header from "../../../shared/components/Header";
import useFundingReportsStore from "../stores/store";
import ReportsSummaryCard from "../components/ReportsSummaryCard";
import ReportsTable from "../components/ReportsTable";
import Pagination from "../../../shared/components/Pagination";
import "../styles/FundingReportsPage.css";
import "../../../shared/styles/common.css";
import "../../../shared/components/layout.css";

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
    isLoadingSummary,
    error,
    fetchReports,
    fetchInitialData,
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

  // 초기 데이터(총 펀딩액, 정산 예정 금액) 로드
  useEffect(() => {
    fetchInitialData();
  }, [fetchInitialData]);

  return (
    <div className="dashboard-layout">
      <Header />
      <Sidebar isOpen={isSidebarOpen} toggleSidebar={toggleSidebar} />

      <main className={`main-content ${isSidebarOpen ? "sidebar-open" : "sidebar-closed"}`}>
        <div className="dashboard-content-area">
          <h1 className="page-title">정산내역</h1>

          <div className="reports-content-wrapper">
            {/* 요약 정보 카드 */}
            <ReportsSummaryCard
              totalAmount={totalAmount ?? 0}
              settlementAmount={settlementAmount ?? 0}
              isLoading={isLoadingSummary}
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
      </main>

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
