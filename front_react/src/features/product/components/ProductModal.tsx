import React, { useEffect } from "react";
import "../styles/productModal.css";
import "../../../shared/styles/common.css";
import { FaTimesCircle } from "react-icons/fa";
import StatisticsChart from "./StatisticsChart";
import RecentTransactions from "./RecentTransactions";
import useProductModalStore from "../store";
import ProductDetails from "./ProductDetails";
import { LoadingSpinner } from "../../../shared";
import { useProductDetails } from "../hooks/useProductDetails";

/**
 * 모달 컴포넌트 - 상품 상세 정보 표시
 */
const ProductModal: React.FC = () => {
  const { isModalOpen, selectedFundingId, closeModal } = useProductModalStore();
  const { productData, loading, error } = useProductDetails(selectedFundingId);

  // ESC 키로 모달 닫기
  useEffect(() => {
    const handleKeyDown = (e: KeyboardEvent) => {
      if (e.key === "Escape" && isModalOpen) {
        closeModal();
      }
    };

    window.addEventListener("keydown", handleKeyDown);

    // 모달 상태에 따른 스크롤 처리
    if (isModalOpen) {
      document.body.style.overflow = "hidden";
    } else {
      document.body.style.overflow = "auto";
    }

    return () => {
      window.removeEventListener("keydown", handleKeyDown);
      document.body.style.overflow = "auto";
    };
  }, [isModalOpen, closeModal]);

  if (!isModalOpen) {
    return null;
  }

  // 모달 외부 클릭 시 닫기
  const handleOverlayClick = (e: React.MouseEvent<HTMLDivElement>) => {
    if (e.target === e.currentTarget) {
      closeModal();
    }
  };

  // 모달 내용 렌더링
  const renderContent = () => {
    if (loading) {
      return (
        <div className="spinner-wrapper">
          <LoadingSpinner message="상품 정보를 불러오는 중입니다..." />
        </div>
      );
    }

    if (error) {
      return (
        <div className="global-error-container">
          <div className="global-error-message">
            <h3>오류가 발생했습니다</h3>
            <p>{error}</p>
            <button
              onClick={closeModal}
              className="global-error-close"
              aria-label="닫기"
            >
              닫기
            </button>
          </div>
        </div>
      );
    }

    if (!productData) {
      return (
        <div className="global-error-container">
          <div className="global-error-message">
            <h3>상품 정보를 찾을 수 없습니다</h3>
            <button
              onClick={closeModal}
              className="global-error-close"
              aria-label="닫기"
            >
              닫기
            </button>
          </div>
        </div>
      );
    }

    return (
      <>
        <ProductDetails
          title={productData.title}
          description={productData.description}
          imageUrl={productData.imageUrl}
          progressPercentage={productData.progressPercentage}
        />

        <div className="product-modal-sections">
          {selectedFundingId && (
            <>
              <StatisticsChart fundingId={selectedFundingId} />
              <RecentTransactions fundingId={selectedFundingId} />
            </>
          )}
        </div>
      </>
    );
  };

  return (
    <div className="modal-overlay" onClick={handleOverlayClick}>
      <div className="product-modal">
        <button
          onClick={closeModal}
          className="close-modal-button"
          aria-label="모달 닫기"
        >
          <FaTimesCircle size={24} />
        </button>
        <div className="product-modal-content">{renderContent()}</div>
      </div>
    </div>
  );
};

export default ProductModal;
