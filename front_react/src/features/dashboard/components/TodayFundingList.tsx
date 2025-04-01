import React from "react";
import { useProductModalStore } from "../../product";
import "../styles/TodayFundingList.css";

interface TodayFundingItem {
  id: string;
  productName: string;
  imageUrl: string; // 유지하지만 아이콘 표시에는 사용 안 함
  category: string; // 카테고리 필드 사용
  totalAmount: number;
  changeAmount: number;
  fundingRate: number;
}

interface TodayFundingListProps {
  data: TodayFundingItem[];
}

// 통화 포맷 함수 (utils로 분리 고려)
const formatCurrency = (amount: number): string => {
  return `${amount.toLocaleString()}원`;
};

// 금액 변화량 포맷 함수 (utils로 분리 고려)
const formatChangeAmount = (change: number): string => {
  const sign = change >= 0 ? "+" : "";
  return `${sign}${change.toLocaleString()}원`;
};

// 개별 펀딩 카드 컴포넌트
const FundingItemCard: React.FC<{ item: TodayFundingItem }> = ({ item }) => {
  const { openModal } = useProductModalStore();
  // 진행률 계산 (100% 초과 시 100으로 제한)
  const progress = Math.min(item.fundingRate, 100);

  const handleCardClick = () => {
    // 유효한 숫자 값으로 변환 시도
    const numericId = Number(item.id);

    // 유효성 검사 추가
    if (isNaN(numericId)) {
      console.error("Invalid item ID:", item.id);
      return;
    }

    // 유효한 ID로만 모달 열기
    console.log("Opening modal for item ID:", numericId);
    openModal(numericId);
  };

  return (
    <div
      className="funding-item-card card-common"
      onClick={handleCardClick}
      style={{ cursor: "pointer" }}
    >
      {/* 이미지 표시 */}
      <img
        src={item.imageUrl}
        alt={item.productName}
        className="funding-card-image"
      />
      <div className="funding-card-body">
        {/* 상품명 및 카테고리 */}
        <div>
          <h4 className="funding-card-name">{item.productName}</h4>
          {/* 카테고리 표시 추가 */}
          <span className="funding-card-category">{item.category}</span>{" "}
        </div>
        {/* 진행률 바 및 퍼센트 */}
        <div className="funding-progress-section">
          {/* 펀딩률 텍스트를 바 위로 이동 */}
          <span
            className={`rate-value ${
              item.fundingRate >= 100 ? "high-rate" : ""
            }`}
          >
            +{item.fundingRate}%
          </span>
          <div className="funding-progress-bar-container">
            <div
              className="funding-progress-bar"
              style={{ width: `${progress}%` }}
            ></div>
          </div>
        </div>
        {/* 금액 및 변화량 (위치 조정) */}
        <div className="funding-card-footer">
          {/* Footer 왼쪽은 비워두거나 다른 정보 추가 가능 */}
          <div className="funding-card-amount">
            <div className="funding-total">
              {formatCurrency(item.totalAmount)}
            </div>
            <div
              className={`funding-change ${
                item.changeAmount >= 0 ? "positive" : "negative"
              }`}
            >
              {formatChangeAmount(item.changeAmount)}
            </div>
          </div>
        </div>
      </div>
    </div>
  );
};

const TodayFundingList: React.FC<TodayFundingListProps> = ({ data }) => {
  // 상위 3개 데이터만 사용
  const top3Data = data.slice(0, 3);
  const hasData = top3Data && top3Data.length > 0;

  return (
    // 감싸는 컨테이너 제거하고 카드 래퍼만 유지
    hasData ? (
      // 카드들을 가로로 배치하기 위한 div
      <div className="funding-cards-wrapper" style={{ height: "100%" }}>
        {top3Data.map((item) => (
          <FundingItemCard key={item.id} item={item} />
        ))}
      </div>
    ) : (
      <div className="no-data-message">오늘 펀딩된 내역이 없습니다.</div>
    )
  );
};

export default TodayFundingList;
