import React, { useState, useRef, useEffect } from "react";
import { Project } from "../services/projectManagementService";
import useProductModalStore from "../../product/store"; // 모달 스토어 import
import "../styles/ProjectManagement.css"; // Import shared styles
import DeleteConfirmModal from "./DeleteConfirmModal"; // 삭제 확인 모달 컴포넌트 import

interface ProjectCardProps {
  project: Project;
  onDeleteProject?: (projectId: number) => void; // 삭제 함수 prop 추가
}

const ProjectCard: React.FC<ProjectCardProps> = ({
  project,
  onDeleteProject,
}) => {
  // 메뉴 표시 상태
  const [showMenu, setShowMenu] = useState(false);
  // 삭제 확인 모달 상태
  const [showDeleteModal, setShowDeleteModal] = useState(false);
  const menuRef = useRef<HTMLDivElement>(null);
  const openModal = useProductModalStore((state) => state.openModal);

  // 가격 포맷팅 (예: 15000 -> 15,000원)
  const formattedPrice = project.price.toLocaleString("ko-KR");

  // 상품이 마감되었는지 확인
  const isFinished =
    !project.remainingTime || project.remainingTime.startsWith("-");

  // 마감된 상품 중 펀딩 성공 여부 (100% 이상인 경우 성공)
  const isSuccess = isFinished && project.progressPercentage >= 100;
  const isFailed = isFinished && project.progressPercentage < 100;

  // 외부 클릭 감지하여 메뉴 닫기
  useEffect(() => {
    const handleClickOutside = (event: MouseEvent) => {
      if (menuRef.current && !menuRef.current.contains(event.target as Node)) {
        setShowMenu(false);
      }
    };

    document.addEventListener("mousedown", handleClickOutside);
    return () => {
      document.removeEventListener("mousedown", handleClickOutside);
    };
  }, []);

  // 메뉴 토글 함수
  const toggleMenu = (e: React.MouseEvent) => {
    e.stopPropagation(); // 카드 클릭 이벤트 전파 방지
    setShowMenu(!showMenu);
  };

  // 삭제 클릭 핸들러
  const handleDeleteClick = (e: React.MouseEvent) => {
    e.stopPropagation();
    setShowDeleteModal(true);
    setShowMenu(false);
  };

  // 삭제 확인 핸들러
  const confirmDelete = (e: React.MouseEvent) => {
    e.stopPropagation();
    onDeleteProject?.(project.fundingId);
    setShowDeleteModal(false);
  };

  // 삭제 취소 핸들러
  const cancelDelete = (e: React.MouseEvent) => {
    e.stopPropagation();
    setShowDeleteModal(false);
  };

  // 진행률 바 스타일 계산
  const progressStyle = {
    width: `${Math.min(project.progressPercentage, 100)}%`, // 최대 100%까지만 표시
    background: getProgressColor(
      project.progressPercentage,
      isFinished,
      isSuccess
    ),
  };

  // 진행률에 따른 색상 결정 (마감 상태도 고려)
  function getProgressColor(
    percentage: number,
    finished: boolean,
    success: boolean
  ): string {
    if (finished) {
      if (success) {
        // 마감된 성공 상품: 그라데이션 초록색
        return "linear-gradient(90deg, #4CAF50, #8BC34A)";
      }
      // 마감된 실패 상품: 회색
      return "#9E9E9E";
    }

    // 진행 중인 상품
    if (percentage >= 100) return "#4CAF50"; // 100% 이상: 초록색
    if (percentage >= 70) return "#8BC34A"; // 70% 이상: 연한 초록색
    if (percentage >= 40) return "#2196F3"; // 40% 이상: 파란색
    return "#FFC107"; // 40% 미만: 노란색
  }

  // 남은 시간 표시 처리 (음수인 경우 '마감'으로 표시)
  const getRemainingTimeDisplay = (remainingTime: string | null): string => {
    if (!remainingTime) return "마감";
    // 만약 남은 시간이 음수로 표현된 경우 (예: -1h-5m)
    if (remainingTime.startsWith("-")) return "마감";
    return `남은 시간: ${remainingTime}`;
  };

  // 이미지 URL 처리 함수 (S3 이미지 로딩 이슈 대응)
  const getImageUrl = (url: string | null): string => {
    if (!url) return "/placeholder-image.png";

    // S3 이미지 URL인 경우
    if (url.includes("s3.ap-northeast-2.amazonaws.com")) {
      // 방법 1: CSP 문제를 해결했다면 원본 URL 사용
      return url;

      // 방법 2: 프록시 API를 통해 이미지 제공 (백엔드에 해당 API가 있는 경우)
      // const imageId = url.split('/').pop(); // URL에서 이미지 ID 추출
      // return `/api/images/proxy?url=${encodeURIComponent(url)}`;

      // 방법 3: 로컬 캐시된 이미지 사용 (미리 다운로드 받은 경우)
      // const imageName = url.split('/').pop();
      // return `/assets/images/${imageName}`;
    }

    return url || "/placeholder-image.png";
  };

  const handleCardClick = () => {
    openModal(project.fundingId);
  };

  // 펀딩 상태 텍스트
  const getFundingStatusText = () => {
    if (!isFinished) return null;

    if (isSuccess) {
      const overPercentage = project.progressPercentage - 100;
      if (overPercentage > 0) {
        return `펀딩 성공 (목표 +${overPercentage.toFixed(0)}%)`;
      }
      return "펀딩 성공 (100%)";
    } else {
      return `펀딩 실패 (${project.progressPercentage.toFixed(0)}%)`;
    }
  };

  // 카드 클래스 - 마감된 상품에 추가 클래스 적용
  const cardClassName = `project-card ${isFinished ? "finished-project" : ""} ${
    isSuccess ? "success-project" : ""
  } ${isFailed ? "failed-project" : ""}`;

  return (
    <>
      <div
        className={cardClassName}
        onClick={handleCardClick}
        role="button"
        tabIndex={0}
        aria-label={`상품 ${project.title} 상세 보기`}
      >
        <div className="project-card-image-container">
          <img
            src={getImageUrl(project.imageUrl)}
            alt={project.title}
            className="project-card-image"
          />
          {isFinished && (
            <div
              className={`finished-overlay ${isSuccess ? "success" : "failed"}`}
            >
              {getFundingStatusText()}
            </div>
          )}
        </div>

        {/* 더보기 메뉴 버튼 (진행 중인 프로젝트에만 표시) */}
        {!isFinished && (
          <div className="project-card-menu" ref={menuRef}>
            <button
              className="more-button"
              onClick={toggleMenu}
              aria-label="프로젝트 관리 메뉴"
            >
              <span className="more-icon">⋮</span>
            </button>

            {showMenu && (
              <div className="project-menu-dropdown">
                <button
                  onClick={handleDeleteClick}
                  className="menu-item delete"
                >
                  프로젝트 삭제
                </button>
              </div>
            )}
          </div>
        )}

        <div className="project-card-content">
          <h3 className="project-card-title">{project.title}</h3>
          <p className="project-card-description">{project.description}</p>
          <div className="project-card-info">
            <span className="project-card-price">{formattedPrice}원</span>
            <span
              className={`project-card-remaining-time ${
                isFinished ? (isSuccess ? "success" : "failed") : ""
              }`}
            >
              {getRemainingTimeDisplay(project.remainingTime)}
            </span>
          </div>
          <div className="project-card-progress-container">
            <div
              className="project-card-progress-bar"
              style={progressStyle}
            ></div>
          </div>
          <span
            className={`project-card-progress-percentage ${
              isSuccess ? "success" : ""
            } ${isFailed ? "failed" : ""}`}
          >
            {project.progressPercentage}%
          </span>
        </div>
      </div>

      {/* 분리된 삭제 확인 모달 컴포넌트 사용 */}
      <DeleteConfirmModal
        title="프로젝트 삭제"
        isOpen={showDeleteModal}
        onConfirm={confirmDelete}
        onCancel={cancelDelete}
      />
    </>
  );
};

export default ProjectCard;
