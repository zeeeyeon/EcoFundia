import React, { useEffect, useState } from "react";
import ProjectSection from "./components/ProjectSection";
import useProjectManagementStore from "./stores/useProjectManagementStore";
import ProductModal from "../product/components/ProductModal";
import { deleteProject } from "./services/projectManagementService";
import "./styles/ProjectManagement.css"; // 올바른 경로로 수정
import Header from "../../shared/components/Header";
import Sidebar from "../../shared/components/Sidebar";
import "../../shared/components/layout.css"; // 레이아웃 스타일 추가
import { ToastContainer, toast } from "react-toastify"; // react-toastify 추가
import "react-toastify/dist/ReactToastify.css"; // 토스트 스타일 추가

/**
 * 상품 관리 페이지 컴포넌트
 * 진행중인 상품과 마감된 상품 목록을 보여주는 페이지
 */
const ProjectManagementPage: React.FC = () => {
  // 사이드바 상태 관리
  const [isSidebarOpen, setIsSidebarOpen] = useState(true);

  // 상태 관리 스토어
  const resetStore = useProjectManagementStore((state) => state.resetStore);
  const refreshProjects = useProjectManagementStore(
    (state) => state.refreshProjects
  );

  // 컴포넌트 언마운트 시 상태 초기화
  useEffect(() => {
    return () => resetStore();
  }, [resetStore]);

  // 사이드바 토글 핸들러
  const toggleSidebar = () => setIsSidebarOpen((prev) => !prev);

  // 프로젝트 삭제 핸들러
  const handleDeleteProject = async (projectId: number) => {
    try {
      // 삭제 API 호출
      const result = await deleteProject(projectId);

      if (result.success) {
        // 프로젝트 목록 새로고침
        refreshProjects();
        toast.success(result.message);
      } else {
        toast.error(result.message);
      }
    } catch (error: unknown) {
      // error 타입을 명시적으로 unknown으로 지정
      console.error("프로젝트 삭제 오류:", error);
      toast.error("프로젝트 삭제 중 오류가 발생했습니다.");
    }
  };

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
          <ProjectSection
            title="진행중인 상품"
            projectType="ongoing"
            onDeleteProject={handleDeleteProject}
          />
          <ProjectSection title="마감된 상품" projectType="finished" />
        </div>
      </main>

      {/* 상품 상세 모달 */}
      <ProductModal />

      {/* 토스트 알림 컨테이너 */}
      <ToastContainer position="bottom-right" autoClose={3000} />
    </div>
  );
};

export default ProjectManagementPage;
