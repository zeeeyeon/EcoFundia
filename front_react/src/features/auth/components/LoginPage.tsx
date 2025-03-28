import React, { useState, useEffect } from "react";
import { useNavigate } from "react-router-dom";
import { useGoogleLogin } from "@react-oauth/google";
import useAuthStore from "../stores/authStore";
import LoadingSpinner from "../../../common/components/LoadingSpinner";
import ErrorMessage from "../../../common/components/ErrorMessage";
import Leaf from "../../../assets/Leaf.svg";
import "./login.css";

// 유틸리티 함수들은 유지하지만 현재는 사용하지 않습니다
// PKCE 방식 대신 Google Identity Services를 사용합니다

const LoginPage: React.FC = () => {
  const navigate = useNavigate();
  const { loginWithGoogle, isLoading: storeLoading } = useAuthStore();
  const [isLoading, setIsLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);

  // 에러 메시지 자동 제거
  useEffect(() => {
    if (error) {
      const timer = setTimeout(() => {
        setError(null);
      }, 3000);
      return () => clearTimeout(timer);
    }
  }, [error]);

  // 구글 로그인 with 액세스 토큰 직접 획득
  const googleLogin = useGoogleLogin({
    onSuccess: async (response: { access_token: string }) => {
      try {
        setIsLoading(true);
        setError(null);

        // 구글에서 직접 액세스 토큰 획득
        const accessToken = response.access_token;
        console.log("구글 액세스 토큰 획득 성공:", accessToken);

        // 백엔드로 액세스 토큰 전송
        const loginResponse = await loginWithGoogle(accessToken);
        console.log("Backend login success:", loginResponse);

        // role에 따른 리다이렉션
        if (loginResponse.role === "USER") {
          navigate("/seller-registration");
        } else {
          navigate("/dashboard");
        }
      } catch (err) {
        console.error("Login error:", err);
        setError(
          err instanceof Error
            ? err.message
            : "로그인에 실패했습니다. 다시 시도해주세요."
        );
      } finally {
        setIsLoading(false);
      }
    },
    onError: () => {
      setError("구글 로그인에 실패했습니다. 다시 시도해주세요.");
    },
    scope: "openid profile email",
  });

  const loading = isLoading || storeLoading;

  return (
    <>
      {loading && <LoadingSpinner />}
      {error && <ErrorMessage message={error} />}
      <div className="login-page">
        <div className="login-card loaded">
          <div className="text-center">
            <div className="leaf-icon">
              <img src={Leaf} alt="Eco Leaf" className="leaf-image" />
            </div>

            <h1 className="title">SIMPLE</h1>
            <p className="description">
              당신의 아이디어가 세상을 푸르게 만듭니다.
              <br />
              로그인하고 시작하세요.
            </p>
          </div>

          <div className="button-container">
            <div className="google-login-wrapper">
              <button
                onClick={() => googleLogin()}
                className="google-custom-button"
              >
                <span className="google-icon">G</span>
                구글 로그인
              </button>
            </div>

            <div className="info-text">
              <p>
                관리자 전용 페이지입니다.
                <br />
                판매자 계정으로만 로그인이 가능합니다.
              </p>
            </div>
          </div>
        </div>
      </div>
    </>
  );
};

export default LoginPage;
