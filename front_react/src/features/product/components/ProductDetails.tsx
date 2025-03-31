import React from "react";
import type { ProductDetailContent } from "../services/productService";

// ProductDetailProps 인터페이스 수정
interface ProductDetailsProps {
  fundingId?: number | null; // 선택적으로 변경
  productData: ProductDetailContent; // 타입 명시
}

const ProductDetails: React.FC<ProductDetailsProps> = ({ productData }) => {
  // 부모 컴포넌트에서 로딩 상태를 처리하므로
  // 여기서는 아무것도 표시하지 않음 (null 반환)
  if (!productData) {
    return null;
  }

  // 진행률에 따른 색상 계산
  const getProgressColor = (percentage: number): string => {
    if (percentage >= 100) return "#4CAF50"; // 녹색 (100% 이상)
    if (percentage >= 70) return "#8BC34A"; // 연두색 (70% 이상)
    if (percentage >= 40) return "#FFC107"; // 노란색 (40% 이상)
    return "#FF5722"; // 붉은색 (40% 미만)
  };

  const progressColor = getProgressColor(productData.progressPercentage);

  return (
    <div className="product-details-section">
      <div className="product-image-container">
        <img
          src={productData.imageUrl || "/placeholder-image.png"}
          alt={productData.title}
          className="product-image"
        />
      </div>

      <div className="product-info">
        <h2 className="product-title">{productData.title}</h2>

        <div className="progress-container">
          <div className="progress-label">
            <span>펀딩 달성률</span>
            <span
              className="progress-percentage"
              style={{ color: progressColor }}
            >
              {productData.progressPercentage}%
            </span>
          </div>
          <div className="progress-bar-container">
            <div
              className="progress-bar"
              style={{
                width: `${Math.min(100, productData.progressPercentage)}%`,
                backgroundColor: progressColor,
              }}
            />
          </div>
        </div>

        <p className="product-description">{productData.description}</p>
      </div>
    </div>
  );
};

export default ProductDetails;
