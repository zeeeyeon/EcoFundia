import React from "react";
import "../styles/ProjectManagement.css";
import ProjectCard from "./ProjectCard";
import "../../../shared/styles/common.css";
import { FaChevronLeft, FaChevronRight } from "react-icons/fa";
import useProjectList from "../hooks/useProjectList";
import { Project } from "../services/projectManagementService";
import { LoadingSpinner } from "../../../shared";

interface ProjectSectionProps {
  title: string;
  projectType: "ongoing" | "finished";
  onDeleteProject?: (projectId: number) => void;
}

const ProjectSection: React.FC<ProjectSectionProps> = ({
  title,
  projectType,
  onDeleteProject,
}) => {
  const {
    projects,
    currentPage,
    isLoading,
    error,
    handlePageChange,
    hasNextPage,
    refreshProjects,
  } = useProjectList(projectType);

  // 에러 초기화 함수
  const resetError = () => {
    refreshProjects();
  };

  // 프로젝트 타입에 따른 한글 문구 처리
  const getKoreanTypeText = () => {
    return projectType === "ongoing" ? "진행중인 상품" : "마감된 상품";
  };

  // UI에 표시할 페이지 번호 (API는 0부터, UI는 1부터)
  const displayPageNumber = currentPage + 1;

  return (
    <div className="project-section-container">
      <div className="project-section-header">
        <h2 className="project-section-title">{title}</h2>

        {/* 페이지네이션 */}
        <div className="pagination-controls">
          <button
            onClick={() => handlePageChange(displayPageNumber - 1)}
            disabled={currentPage === 0}
            className="page-button"
            aria-label="이전 페이지"
          >
            <FaChevronLeft />
          </button>
          <span className="page-indicator">페이지 {displayPageNumber}</span>
          <button
            onClick={() => handlePageChange(displayPageNumber + 1)}
            disabled={!hasNextPage}
            className="page-button"
            aria-label="다음 페이지"
          >
            <FaChevronRight />
          </button>
        </div>
      </div>

      {isLoading && (
        <div className="loading-container">
          <LoadingSpinner message={`${getKoreanTypeText()} 불러오는 중...`} />
        </div>
      )}

      {error && (
        <div className="global-error-container">
          <div className="global-error-message">
            <h3>프로젝트 오류</h3>
            <p>{error}</p>
            <button className="global-error-close" onClick={resetError}>
              확인
            </button>
          </div>
        </div>
      )}

      {!isLoading && !error && projects.length === 0 && (
        <div className="no-projects-container">
          <p>{getKoreanTypeText()}이 없습니다.</p>
        </div>
      )}

      {!isLoading && !error && projects.length > 0 && (
        <div className="project-grid">
          {projects.map((project: Project) => (
            <ProjectCard
              key={project.fundingId}
              project={project}
              onDeleteProject={
                projectType === "ongoing" ? onDeleteProject : undefined
              }
            />
          ))}
        </div>
      )}
    </div>
  );
};

export default ProjectSection;
