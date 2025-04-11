import React, { useEffect } from 'react';
import { BrowserRouter as Router } from 'react-router-dom';
import { GoogleOAuthProvider } from "@react-oauth/google";
import AppRouter from './router';
import { ThemeProvider } from './shared/contexts/ThemeContext';
import useAuthStore from './features/auth/stores/store';
import './index.css';

function App() {
  const googleClientId = import.meta.env.VITE_GOOGLE_CLIENT_ID || "";
  const initAuth = useAuthStore(state => state.initAuth);

  // 앱 시작 시 인증 상태 초기화
  useEffect(() => {
    console.log("App 컴포넌트 마운트 - 인증 상태 초기화 시작");
    initAuth();
    console.log("인증 상태 초기화 함수 호출 완료");
  }, [initAuth]);

  if (!googleClientId) {
    console.error("Google Client ID가 설정되지 않았습니다. .env 파일을 확인하세요.");
    return <div>Google Client ID 설정 오류</div>;
  }

  return (
    <React.StrictMode>
      <GoogleOAuthProvider clientId={googleClientId}>
        <ThemeProvider>
          <Router>
            <AppRouter />
          </Router>
        </ThemeProvider>
      </GoogleOAuthProvider>
    </React.StrictMode>
  );
}

export default App;
