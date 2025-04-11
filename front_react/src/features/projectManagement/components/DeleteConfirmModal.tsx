import React, { useEffect, useRef } from "react";
import "../styles/ProjectManagement.css";

interface DeleteConfirmModalProps {
  title: string;
  onConfirm: (e: React.MouseEvent) => void;
  onCancel: (e: React.MouseEvent) => void;
  isOpen: boolean;
}

const DeleteConfirmModal: React.FC<DeleteConfirmModalProps> = ({
  title,
  onConfirm,
  onCancel,
  isOpen,
}) => {
  const modalRef = useRef<HTMLDivElement>(null);

  // 외부 클릭 감지하여 모달 닫기
  useEffect(() => {
    const handleClickOutside = (event: MouseEvent) => {
      if (
        isOpen &&
        modalRef.current &&
        !modalRef.current.contains(event.target as Node)
      ) {
        onCancel(event as unknown as React.MouseEvent);
      }
    };

    document.addEventListener("mousedown", handleClickOutside);
    return () => {
      document.removeEventListener("mousedown", handleClickOutside);
    };
  }, [isOpen, onCancel]);

  // ESC 키 감지하여 모달 닫기
  useEffect(() => {
    const handleEscKey = (event: KeyboardEvent) => {
      if (event.key === "Escape" && isOpen) {
        onCancel(event as unknown as React.MouseEvent);
      }
    };

    document.addEventListener("keydown", handleEscKey);
    return () => {
      document.removeEventListener("keydown", handleEscKey);
    };
  }, [isOpen, onCancel]);

  if (!isOpen) return null;

  return (
    <div className="delete-modal-overlay">
      <div className="delete-modal" ref={modalRef}>
        <div className="delete-modal-icon">
          <svg
            width="24"
            height="24"
            viewBox="0 0 24 24"
            fill="none"
            xmlns="http://www.w3.org/2000/svg"
          >
            <circle cx="12" cy="12" r="12" fill="#FFEBEE" />
            <path
              d="M12 7V13"
              stroke="#E53935"
              strokeWidth="2"
              strokeLinecap="round"
            />
            <circle cx="12" cy="16" r="1" fill="#E53935" />
          </svg>
        </div>
        <h2 className="delete-modal-title">{title}</h2>
        <p className="delete-modal-message">
          프로젝트의 모든 데이터가 영구적으로 삭제됩니다. 이 작업은 되돌릴 수
          없습니다.
        </p>
        <div className="delete-modal-actions">
          <button onClick={onConfirm} className="btn-delete">
            삭제
          </button>
          <button onClick={onCancel} className="btn-cancel">
            취소
          </button>
        </div>
      </div>
    </div>
  );
};

export default DeleteConfirmModal;
