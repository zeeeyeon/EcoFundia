import React from "react";
import { UseFormRegister, FieldErrors } from "react-hook-form";
import { ProductFormData, categoryOptions } from "../../hooks/useProductForm";
import "../../styles/ProductRegistrationForm.css";

interface BasicInfoFormProps {
  register: UseFormRegister<ProductFormData>;
  errors: FieldErrors<ProductFormData>;
  tomorrowDate: string;
}

const BasicInfoForm: React.FC<BasicInfoFormProps> = ({
  register,
  errors,
  tomorrowDate,
}) => {
  return (
    <>
      {/* 상품명 */}
      <div className="prod-form-section">
        <div className="prod-label-area">상품명</div>
        <div className="prod-input-area">
          <div className="prod-form-group">
            <input
              id="title"
              type="text"
              className="prod-input-text"
              placeholder="상품명을 입력하세요 ex) 따뜻한 환경 칫솔"
              {...register("title")}
            />
            {errors.title && (
              <p className="prod-error-msg">{errors.title.message}</p>
            )}
          </div>
        </div>
      </div>

      {/* 상품 소개 */}
      <div className="prod-form-section">
        <div className="prod-label-area">상품 소개</div>
        <div className="prod-input-area">
          <div className="prod-form-group">
            <input
              id="description"
              type="text"
              className="prod-input-text"
              style={{ width: "95%" }}
              placeholder="ex) 나무로 만든 친환경 칫솔."
              {...register("description")}
            />
            {errors.description && (
              <p className="prod-error-msg">{errors.description.message}</p>
            )}
          </div>
        </div>
      </div>

      {/* 카테고리 */}
      <div className="prod-form-section">
        <div className="prod-label-area">카테고리</div>
        <div className="prod-input-area">
          <div className="prod-form-group">
            <div className="prod-category-select">
              <select
                id="category"
                className="prod-select"
                {...register("category")}
              >
                <option value="">카테고리 선택</option>
                {categoryOptions.map((option) => (
                  <option key={option.value} value={option.value}>
                    {option.label}
                  </option>
                ))}
              </select>
            </div>
            {errors.category && (
              <p className="prod-error-msg">{errors.category.message}</p>
            )}
          </div>
        </div>
      </div>

      {/* 판매 가격 */}
      <div className="prod-form-section">
        <div className="prod-label-area">판매 가격</div>
        <div className="prod-input-area">
          <div className="prod-form-group">
            <div className="prod-price-area">
              <input
                id="price"
                type="number"
                className="prod-price-input"
                placeholder="판매 가격을 숫자만 입력해주세요"
                min="1"
                {...register("price")}
              />
              <span className="prod-unit-label">원</span>
            </div>
            {errors.price && (
              <p className="prod-error-msg">{errors.price.message}</p>
            )}
          </div>
        </div>
      </div>

      {/* 펀딩 목표 금액 */}
      <div className="prod-form-section">
        <div className="prod-label-area">목표 금액</div>
        <div className="prod-input-area">
          <div className="prod-form-group">
            <div className="prod-target-area">
              <input
                id="targetAmount"
                type="number"
                className="prod-target-input"
                placeholder="목표 금액을 숫자만 입력해주세요"
                min="1"
                {...register("targetAmount")}
              />
              <span className="prod-unit-label">원</span>
            </div>
            {errors.targetAmount && (
              <p className="prod-error-msg">{errors.targetAmount.message}</p>
            )}
          </div>
        </div>
      </div>

      {/* 펀딩 마감일 */}
      <div className="prod-form-section">
        <div className="prod-label-area">마감일</div>
        <div className="prod-input-area">
          <div className="prod-form-group">
            <div className="prod-date-area">
              <input
                id="endDate"
                type="date"
                className="prod-input-date"
                min={tomorrowDate}
                {...register("endDate")}
              />
            </div>
            {errors.endDate && (
              <p className="prod-error-msg">{errors.endDate.message}</p>
            )}
          </div>
        </div>
      </div>
    </>
  );
};

export default BasicInfoForm;
