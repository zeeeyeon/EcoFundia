import React from "react";
import "../../styles/ProductRegistrationForm.css";

interface FormButtonsProps {
  isLoading: boolean;
  handleReset: () => void;
  handleSubmitForm: () => void;
}

const FormButtons: React.FC<FormButtonsProps> = ({
  isLoading,
  handleReset,
  handleSubmitForm,
}) => {
  return (
    <div className="prod-btn-container">
      <button type="button" className="prod-reset-btn" onClick={handleReset}>
        초기화
      </button>
      <button
        type="button"
        className="prod-submit-btn"
        onClick={handleSubmitForm}
        disabled={isLoading}
      >
        {isLoading ? "등록 중... 파일 업로드 중입니다" : "상품 등록"}
      </button>
    </div>
  );
};

export default FormButtons;
