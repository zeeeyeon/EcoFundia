import React from "react";
import "../styles/productDetails.css";

// ProductDetailProps 인터페이스 수정
interface ProductDetailsProps {
  title: string;
  description: string;
  imageUrl: string;
  progressPercentage: number;
}

const ProductDetails: React.FC<ProductDetailsProps> = ({
  title,
  description,
  imageUrl,
  progressPercentage,
}) => {
  // 진행률에 따른 색상 계산
  const getProgressColor = (percentage: number): string => {
    if (percentage >= 100) return "#b6e62e"; // 녹색 (100% 이상)
    if (percentage >= 70) return "#8BC34A"; // 연두색 (70% 이상)
    if (percentage >= 40) return "#FFC107"; // 노란색 (40% 이상)
    return "#FF5722"; // 붉은색 (40% 미만)
  };

  const progressColor = getProgressColor(progressPercentage);

  return (
    <div className="product-details-section">
      <div className="product-image-container">
        <img
          src={imageUrl || "/placeholder-image.png"}
          alt={title}
          className="product-image"
        />
      </div>

      <div className="product-info">
        <h2 className="product-title">{title}</h2>
        <p className="product-description">{description}</p>
        <div className="product-progress-container">
          <div className="product-progress-label">
            <span>펀딩 달성률</span>
            <span
              className="product-progress-percentage"
              style={{ color: progressColor }}
            >
              {progressPercentage}%
            </span>
          </div>
          <div className="product-progress-bar-container">
            <div
              className="product-progress-bar"
              style={{
                width: `${Math.min(100, progressPercentage)}%`,
                backgroundColor: progressColor,
              }}
            />
          </div>
        </div>
      </div>
    </div>
  );
};

export default ProductDetails;
