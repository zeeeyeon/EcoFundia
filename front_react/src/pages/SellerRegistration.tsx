import React, { useState } from "react";
import { useNavigate } from "react-router-dom";
import useAuthStore from "../stores/authStore";
import LoadingSpinner from "../components/LoadingSpinner";
import Modal from "../components/Modal";
import ErrorModal from "../components/ErrorModal";
import Leaf from "../assets/Leaf.svg";
import "./sellerRegistration.css";

const SellerRegistration: React.FC = () => {
  const navigate = useNavigate();
  const { registerSeller, isLoading: storeLoading, user } = useAuthStore();
  const [formData, setFormData] = useState({
    businessName: "",
    businessNumber: "",
  });
  const [isLoading, setIsLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [showErrorModal, setShowErrorModal] = useState(false);
  const [agreed, setAgreed] = useState(false);
  const [showSuccessModal, setShowSuccessModal] = useState(false);

  // 실제 로딩 상태 합성
  const loading = isLoading || storeLoading;

  const handleChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const { name, value } = e.target;
    setFormData((prev) => ({
      ...prev,
      [name]: value,
    }));
  };

  const getErrorMessage = (error: Error): string => {
    if (error instanceof Error) {
      // 서버 응답의 특정 에러 코드나 메시지에 따라 다른 메시지 반환
      if (error.message.includes("이미 등록된 사업자")) {
        return "이미 등록된 사업자 번호입니다. 다른 번호를 사용해주세요.";
      }
      if (error.message.includes("유효하지 않은 사업자")) {
        return "유효하지 않은 사업자 번호입니다. 다시 확인해주세요.";
      }
      return error.message;
    }
    return "판매자 등록 중 오류가 발생했습니다. 잠시 후 다시 시도해주세요.";
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!agreed) {
      setError("판매자 이용약관에 동의해주세요.");
      setShowErrorModal(true);
      return;
    }
    setIsLoading(true);
    setError(null);

    try {
      await registerSeller(formData.businessName, formData.businessNumber);
      setShowSuccessModal(true);
    } catch (err) {
      const errorMessage = getErrorMessage(err as Error);
      setError(errorMessage);
      setShowErrorModal(true);
    } finally {
      setIsLoading(false);
    }
  };

  const handleModalConfirm = () => {
    setShowSuccessModal(false);
    navigate("/");
  };

  const handleErrorModalClose = () => {
    setShowErrorModal(false);
    setError(null);
  };

  return (
    <>
      {loading && <LoadingSpinner />}

      <ErrorModal
        isOpen={showErrorModal}
        onClose={handleErrorModalClose}
        message={error || ""}
      />

      <Modal
        isOpen={showSuccessModal}
        onClose={handleModalConfirm}
        title="등록 완료"
      >
        <p>판매자로 등록되었습니다.</p>
        <p>다시 로그인해주세요.</p>
        <button
          onClick={handleModalConfirm}
          className="mt-4 px-4 py-2 bg-primary text-white rounded hover:bg-primary-dark"
        >
          확인
        </button>
      </Modal>

      <div className="registration-page">
        <div className="registration-card">
          <div className="leaf-icon">
            <img src={Leaf} alt="Eco Leaf" className="leaf-image" />
          </div>

          <h1 className="title">판매자 등록</h1>
          <p className="description">
            에코펀딩에서 판매자가 되어 친환경 제품을 소개해보세요
          </p>

          {user && (
            <div className="user-info">
              <p>
                <span className="user-name">{user.name}</span>님, 환영합니다!
              </p>
            </div>
          )}

          <form onSubmit={handleSubmit} className="registration-form">
            <div className="form-group">
              <label htmlFor="businessName">상호명</label>
              <input
                type="text"
                id="businessName"
                name="businessName"
                value={formData.businessName}
                onChange={handleChange}
                placeholder="사업자등록증의 상호명을 입력하세요"
                required
              />
            </div>

            <div className="form-group">
              <label htmlFor="businessNumber">사업자 등록번호</label>
              <input
                type="text"
                id="businessNumber"
                name="businessNumber"
                value={formData.businessNumber}
                onChange={handleChange}
                placeholder="000-00-00000"
                required
              />
            </div>

            <div className="warning-box">
              <h3>판매자 주의사항</h3>
              <ul>
                <li>허위 상품 등록 시 즉시 판매자 자격이 박탈됩니다.</li>
                <li>
                  등록된 정보가 사실과 다를 경우 법적 책임이 따를 수 있습니다.
                </li>
                <li>친환경 제품 인증서를 반드시 첨부해야 합니다.</li>
              </ul>
            </div>

            <div className="agreement-box">
              <label className="checkbox-label">
                <input
                  type="checkbox"
                  checked={agreed}
                  onChange={(e) => setAgreed(e.target.checked)}
                />
                <span>위 주의사항을 모두 확인했으며, 이에 동의합니다.</span>
              </label>
            </div>

            <button
              type="submit"
              className="submit-button"
              disabled={loading || !agreed}
            >
              {loading ? <span className="button-loading"></span> : "등록하기"}
            </button>
          </form>
        </div>
      </div>
    </>
  );
};

export default SellerRegistration;
