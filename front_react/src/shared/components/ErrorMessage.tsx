import React from "react";
import "../styles/common.css";

interface ErrorMessageProps {
  message: string;
  onClose?: () => void;
}

const ErrorMessage: React.FC<ErrorMessageProps> = ({ message, onClose }) => {
  return (
    <div className="global-error-container">
      <div className="global-error-message">
        <h3>오류 발생</h3>
        <p>{message}</p>
        {onClose && (
          <button className="global-error-close" onClick={onClose}>
            확인
          </button>
        )}
      </div>
    </div>
  );
};

export default ErrorMessage;
