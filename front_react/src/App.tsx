import { BrowserRouter as Router, Routes, Route } from "react-router-dom";
import { GoogleOAuthProvider } from "@react-oauth/google";
import LoginPage from "./features/auth/components/LoginPage";
import SellerRegistrationPage from "./features/seller/components/SellerRegistrationPage";
import DashboardPage from "./pages/DashboardPage";
import PrivateRoute from "./components/PrivateRoute";

function App() {
  // Google OAuth 클라이언트 ID
  const googleClientId = import.meta.env.VITE_GOOGLE_CLIENT_ID || "";

  return (
    <GoogleOAuthProvider clientId={googleClientId}>
      <Router>
        <Routes>
          {/* 공개 라우트 */}
          <Route path="/" element={<LoginPage />} />
          <Route path="/login" element={<LoginPage />} />

          {/* 인증 필요 라우트 */}
          <Route
            path="/seller-registration"
            element={<SellerRegistrationPage />}
          />

          {/* 판매자 전용 라우트 */}
          <Route element={<PrivateRoute requiredRole="SELLER" />}>
            <Route path="/dashboard" element={<DashboardPage />} />
            {/* 추후 다른 관리자 페이지 추가 예정 */}
          </Route>

          {/* 404 페이지 */}
          <Route path="*" element={<div>페이지를 찾을 수 없습니다.</div>} />
        </Routes>
      </Router>
    </GoogleOAuthProvider>
  );
}

export default App;
