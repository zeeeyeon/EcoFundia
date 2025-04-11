import React from "react";
import "../../styles/ProductRegistrationForm.css";

interface ErrorOverlayProps {
  error: string | null;
  resetError: () => void;
}

const ErrorOverlay: React.FC<ErrorOverlayProps> = ({ error, resetError }) => {
  if (!error) return null;

  return (
    <div className="global-error-container">
      <div className="global-error-message">
        <h3>상품 등록 오류</h3>
        <p>{error}</p>
        <button className="global-error-close" onClick={resetError}>
          확인
        </button>
      </div>
    </div>
  );
};

export default ErrorOverlay;
