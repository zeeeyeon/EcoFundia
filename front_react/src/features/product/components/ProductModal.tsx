import React, { useState, useEffect, useRef } from "react";
import "../styles/productModal.css";
import { FaTimesCircle } from "react-icons/fa";
import StatisticsChart from "./StatisticsChart";
import RecentTransactions from "./RecentTransactions";
import useProductModalStore from "../store";
import ProductDetails from "./ProductDetails";
import { LoadingSpinner } from "../../../shared";
import type { ProductDetailContent } from "../services/productService";

// --- 더미 상품 상세 데이터 ---
const dummyProductDetails: ProductDetailContent = {
  fundingId: 999, // 예시 ID
  title: "친환경 대나무 칫솔 (더미 데이터)",
  description:
    "지구를 생각하는 당신의 선택! 100% 생분해되는 대나무로 만든 칫솔입니다. 플라스틱 사용을 줄이고 지속가능한 생활을 실천하세요. 부드러운 미세모가 잇몸 자극 없이 깨끗하게 닦아줍니다.",
  imageUrl: "/test1.png", // public 폴더의 이미지 경로 또는 외부 URL
  progressPercentage: 82,
};
// ------------------------

/**
 * 상품 상세 정보를 조회하는 훅 (현재 더미 데이터 사용)
 * @param fundingId 펀딩 상품 ID (현재 사용되지 않음)
 */
export const useProductDetails = (fundingId: number | null) => {
  const [productData, setProductData] = useState<ProductDetailContent | null>(
    null
  );
  const [loading, setLoading] = useState<boolean>(false);
  const [error, setError] = useState<string | null>(null);
  const timerRef = useRef<ReturnType<typeof setTimeout> | null>(null);

  // 이미 로딩 중인지 추적하는 ref
  const isLoadingRef = useRef<boolean>(false);

  useEffect(() => {
    console.log(`[useProductDetails Effect] Start - fundingId: ${fundingId}`);

    // 항상 먼저 상태 초기화 (이전 데이터 제거)
    setProductData(null);
    setError(null);

    // 이전 타이머가 있으면 정리
    if (timerRef.current) {
      clearTimeout(timerRef.current);
      timerRef.current = null;
    }

    // fundingId가 null이거나 유효하지 않은 경우(NaN) 처리
    if (fundingId === null || isNaN(fundingId)) {
      console.log(
        `[useProductDetails Effect] Invalid fundingId: ${fundingId}. Keeping loading false.`
      );
      isLoadingRef.current = false;
      return;
    }

    // 이미 로딩 중이면 중복 요청 방지
    if (isLoadingRef.current) {
      console.log(
        `[useProductDetails Effect] Already loading for fundingId: ${fundingId}. Skipping.`
      );
      return;
    }

    // 로딩 시작
    isLoadingRef.current = true;
    setLoading(true);
    console.log("[useProductDetails Effect] Loading started.");

    // 실제 API 호출 대신 더미 데이터 설정 (setTimeout으로 로딩 효과 연출)
    timerRef.current = setTimeout(() => {
      console.log(
        `[useProductDetails Effect] setTimeout callback start - fundingId: ${fundingId}`
      );
      try {
        // 현재 선택된 fundingId와 일치하는 데이터만 설정 (데이터 혼선 방지)
        const dataToSet = {
          ...dummyProductDetails,
          fundingId: fundingId, // 요청 ID를 응답 데이터에 정확히 반영
        };
        setProductData(dataToSet);
        console.log(
          `[useProductDetails Effect] Dummy data loaded (Requested ID: ${fundingId})`
        );
      } catch (error) {
        setError("데이터 로드 중 오류가 발생했습니다");
        console.error("[useProductDetails Effect] Error loading data:", error);
      } finally {
        // 로딩 상태 종료
        console.log(
          "[useProductDetails Effect] setTimeout callback finish - Setting loading to false."
        );
        setLoading(false);
        isLoadingRef.current = false;
        timerRef.current = null;
      }
    }, 1000); // 1초로 단축

    return () => {
      // 컴포넌트 언마운트 또는 fundingId 변경 시 cleanup
      console.log(
        `[useProductDetails Effect Cleanup] fundingId: ${fundingId}, clearing timer`
      );
      if (timerRef.current) {
        clearTimeout(timerRef.current);
        timerRef.current = null;
      }
      isLoadingRef.current = false;
    };
  }, [fundingId]);

  return { productData, loading, error };
};

/**
 * 모달 컴포넌트 - 상품 상세 정보 표시
 * 모든 상태를 컴포넌트 내부에서 직접 관리하여 외부 훅 의존도 제거
 */
const ProductModal: React.FC = () => {
  const { isModalOpen, selectedFundingId, closeModal } = useProductModalStore();

  // 상태 관리
  const [productData, setProductData] = useState<ProductDetailContent | null>(
    null
  );
  const [loading, setLoading] = useState<boolean>(false);
  const [error, setError] = useState<string | null>(null);
  const timerRef = useRef<ReturnType<typeof setTimeout> | null>(null);

  // 모든 데이터가 완전히 준비되었는지 확인하는 조건
  const isFullyReady =
    !loading &&
    productData !== null &&
    !error &&
    selectedFundingId !== null &&
    productData.fundingId === selectedFundingId;

  // 데이터 로딩 함수
  const loadProductData = (fundingId: number) => {
    if (!fundingId || isNaN(fundingId)) {
      setError("유효하지 않은 상품 ID입니다.");
      setLoading(false);
      return;
    }

    // 로딩 시작
    setLoading(true);
    setError(null);

    // 기존 타이머 정리
    if (timerRef.current) {
      clearTimeout(timerRef.current);
      timerRef.current = null;
    }

    // 실제 API 호출 대신 더미 데이터 설정 (타이머로 지연)
    timerRef.current = setTimeout(() => {
      try {
        // 현재 선택된 fundingId와 일치하는 데이터만 설정
        const dataToSet = {
          ...dummyProductDetails,
          fundingId: fundingId,
        };
        setProductData(dataToSet);
      } catch {
        setError("데이터 로드 중 오류가 발생했습니다.");
      } finally {
        setLoading(false);
        timerRef.current = null;
      }
    }, 1000);
  };

  // 모달이 열리거나 닫힐 때 상태 관리
  useEffect(() => {
    if (isModalOpen && selectedFundingId) {
      // 모달이 열리면 데이터 로딩 시작
      loadProductData(selectedFundingId);
    } else {
      // 모달이 닫히면 상태 초기화
      setProductData(null);
      setLoading(false);
      setError(null);

      // 타이머 정리
      if (timerRef.current) {
        clearTimeout(timerRef.current);
        timerRef.current = null;
      }
    }

    return () => {
      // 컴포넌트 언마운트 또는 isModalOpen/selectedFundingId 변경 시 타이머 정리
      if (timerRef.current) {
        clearTimeout(timerRef.current);
        timerRef.current = null;
      }
    };
  }, [isModalOpen, selectedFundingId]);

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
        <div className="error-message">
          <h3>오류가 발생했습니다</h3>
          <p>{error}</p>
        </div>
      );
    }

    if (!isFullyReady) {
      return (
        <div className="spinner-wrapper">
          <LoadingSpinner message="데이터 준비 중..." />
        </div>
      );
    }

    // 모든 상태가 완벽히 준비된 경우에만 실제 컨텐츠 표시
    return (
      <div className="all-product-content show">
        <div>
          <ProductDetails productData={productData} />
        </div>
        <div className="modal-sections">
          <div className="modal-section">
            <StatisticsChart />
          </div>
          <div className="modal-section">
            <RecentTransactions />
          </div>
        </div>
      </div>
    );
  };

  return (
    <div className="modal-overlay" onClick={handleOverlayClick}>
      <div className="modal-content">
        <button className="modal-close-button" onClick={closeModal}>
          <FaTimesCircle />
        </button>
        <div className="modal-body">{renderContent()}</div>
      </div>
    </div>
  );
};

export default ProductModal;
