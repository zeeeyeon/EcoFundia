import React, { useEffect, useState } from "react";
import ProjectSection from "./components/ProjectSection";
import useProjectManagementStore from "./stores/useProjectManagementStore";
import ProductModal from "../product/components/ProductModal";
import "./styles/ProjectManagement.css"; // 올바른 경로로 수정
import Header from "../../shared/components/Header";
import Sidebar from "../../shared/components/Sidebar";
import "../../shared/components/layout.css"; // 레이아웃 스타일 추가

/**
 * 상품 관리 페이지 컴포넌트
 * 진행중인 상품과 마감된 상품 목록을 보여주는 페이지
 */
const ProjectManagementPage: React.FC = () => {
  // 사이드바 상태 관리
  const [isSidebarOpen, setIsSidebarOpen] = useState(true);

  // 상태 관리 스토어
  const resetStore = useProjectManagementStore((state) => state.resetStore);

  // 컴포넌트 언마운트 시 상태 초기화
  useEffect(() => {
    return () => resetStore();
  }, [resetStore]);

  // 사이드바 토글 핸들러
  const toggleSidebar = () => setIsSidebarOpen((prev) => !prev);

  return (
    <div className="dashboard-layout">
      <Header />
      <Sidebar isOpen={isSidebarOpen} toggleSidebar={toggleSidebar} />

      <main
        className={`main-content ${
          isSidebarOpen ? "sidebar-open" : "sidebar-closed"
        }`}
      >
        <div className="dashboard-content-area project-management-page">
          <h1 className="page-title">상품 관리</h1>
          <ProjectSection title="진행중인 상품" projectType="ongoing" />
          <ProjectSection title="마감된 상품" projectType="finished" />
        </div>
      </main>

      {/* 상품 상세 모달 */}
      <ProductModal />
    </div>
  );
};

export default ProjectManagementPage;
