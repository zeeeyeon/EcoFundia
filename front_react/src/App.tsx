import React from 'react';
import { BrowserRouter as Router } from 'react-router-dom';
import { GoogleOAuthProvider } from "@react-oauth/google";
import AppRouter from './router';
import { ThemeProvider } from './shared/contexts/ThemeContext';
import './index.css';

function App() {
  const googleClientId = import.meta.env.VITE_GOOGLE_CLIENT_ID || "";

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
