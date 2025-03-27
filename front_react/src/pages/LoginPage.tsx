import React, { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import useAuthStore from '../stores/authStore';
import LoadingSpinner from '../components/LoadingSpinner';
import ErrorMessage from '../components/ErrorMessage';
import Leaf from '../assets/Leaf.svg';
import './login.css';

interface LoginResponse {
  user: {
    id: string;
    email: string;
    role: string;
  };
  accessToken: string;
  refreshToken: string;
}

const LoginPage: React.FC = () => {
  const navigate = useNavigate();
  const { login } = useAuthStore();
  const [isLoading, setIsLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);

  // 에러 메시지 자동 제거
  React.useEffect(() => {
    if (error) {
      const timer = setTimeout(() => {
        setError(null);
      }, 3000);
      return () => clearTimeout(timer);
    }
  }, [error]);

  const handleGoogleLogin = async () => {
    try {
      setIsLoading(true);
      setError(null);

      // 임시로 성공 응답 모의
      const mockResponse: LoginResponse = {
        user: {
          id: '1',
          email: 'seller@example.com',
          role: 'seller'
        },
        accessToken: 'mock-access-token',
        refreshToken: 'mock-refresh-token'
      };

      // 실제 구현 시 아래 주석을 해제하고 사용
      // const { data } = await api.post<LoginResponse>('/user/login', { token: 'your-token' });

      // 토큰을 세션 스토리지에 저장
      sessionStorage.setItem('accessToken', mockResponse.accessToken);
      sessionStorage.setItem('refreshToken', mockResponse.refreshToken);

      // 로그인 상태 업데이트
      login({
        user: mockResponse.user,
        accessToken: mockResponse.accessToken,
        refreshToken: mockResponse.refreshToken,
      });

      // role에 따른 리다이렉션
      if (mockResponse.user.role !== 'seller') {
        navigate('/register');
      } else {
        navigate('/dashboard');
      }
    } catch (error: any) {
      console.error('Login failed:', error);
      setError(error.response?.data?.message || '로그인에 실패했습니다. 다시 시도해주세요.');
    } finally {
      setIsLoading(false);
    }
  };

  return (
    <>
      {isLoading && <LoadingSpinner />}
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
            <button
              onClick={handleGoogleLogin}
              disabled={isLoading}
              className="btn btn-primary w-full google-btn"
            >
              <img
                src="https://developers.google.com/identity/images/g-logo.png"
                alt="Google"
                className="google-logo"
              />
              구글 계정으로 계속하기
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
    </>
  );
};

export default LoginPage; 