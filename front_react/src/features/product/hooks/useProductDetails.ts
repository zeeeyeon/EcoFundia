import { useState, useEffect, useRef } from "react";
import { ProductDetailContent, getProductDetails } from "../services/productService";

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