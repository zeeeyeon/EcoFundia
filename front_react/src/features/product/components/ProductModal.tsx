import React, { useState, useEffect, useRef } from "react";
import "../styles/productModal.css";
import "../../../shared/styles/common.css";
import { FaTimesCircle } from "react-icons/fa";
import StatisticsChart from "./StatisticsChart";
import RecentTransactions from "./RecentTransactions";
import useProductModalStore from "../store";
import ProductDetails from "./ProductDetails";
import { LoadingSpinner } from "../../../shared";
import {
  ProductDetailContent,
  getProductDetails,
} from "../services/productService";

/**
 * 상품 상세 정보를 조회하는 훅
 * @param fundingId 펀딩 상품 ID
 */
export const useProductDetails = (fundingId: number | null) => {
  const [productData, setProductData] = useState<ProductDetailContent | null>(
    null
  );
  const [loading, setLoading] = useState<boolean>(false);
  const [error, setError] = useState<string | null>(null);

  // 이미 로딩 중인지 추적하는 ref
  const isLoadingRef = useRef<boolean>(false);
  const abortControllerRef = useRef<AbortController | null>(null);

  useEffect(() => {
    // 항상 먼저 상태 초기화 (이전 데이터 제거)
    setProductData(null);
    setError(null);

    // 이전 요청 취소
    if (abortControllerRef.current) {
      abortControllerRef.current.abort();
      abortControllerRef.current = null;
    }

    // fundingId가 null이거나 유효하지 않은 경우(NaN) 처리
    if (fundingId === null || isNaN(fundingId)) {
      isLoadingRef.current = false;
      return;
    }

    // 이미 로딩 중이면 중복 요청 방지
    if (isLoadingRef.current) {
      return;
    }

    // 로딩 시작
    isLoadingRef.current = true;
    setLoading(true);

    // 새로운 AbortController 생성
    abortControllerRef.current = new AbortController();

    // API 호출
    const fetchData = async () => {
      try {
        const data = await getProductDetails(fundingId);

        // 요청이 취소된 경우 상태 업데이트 하지 않음
        if (abortControllerRef.current?.signal.aborted) {
          return;
        }

        setProductData(data);
      } catch (error) {
        // 요청이 취소된 경우 상태 업데이트 하지 않음
        if (abortControllerRef.current?.signal.aborted) {
          return;
        }

        console.error("Error fetching product details:", error);
        setError("상품 정보를 불러오는데 실패했습니다");
      } finally {
        // 요청이 취소된 경우 상태 업데이트 하지 않음
        if (
          !abortControllerRef.current ||
          !abortControllerRef.current.signal.aborted
        ) {
          setLoading(false);
          isLoadingRef.current = false;
        }
      }
    };

    fetchData();

    return () => {
      // 컴포넌트 언마운트 또는 fundingId 변경 시 cleanup
      if (abortControllerRef.current) {
        abortControllerRef.current.abort();
        abortControllerRef.current = null;
      }
      isLoadingRef.current = false;
    };
  }, [fundingId]);

  return { productData, loading, error };
};

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
