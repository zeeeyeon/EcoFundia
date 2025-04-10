import React, { useEffect, useState } from "react";
import { Routes, Route, Navigate, useLocation, useNavigate } from "react-router-dom";
import LoginPage from "../features/auth/LoginPage"; // 경로 수정
import RegisterPage from "../features/register/RegisterPage"; // 경로 수정 및 이름 변경
import DashboardPage from "../features/dashboard/DashboardPage"; // 경로 수정
import ProjectManagementPage from "../features/projectManagement/ProjectManagementPage"; // 경로 수정
import ProductRegistrationPage from "../features/productRegistration/ProductRegistrationPage"; // 경로 수정
import FundingReportsPage from "../features/fundingReports/pages/FundingReportsPage"; // 정산내역 페이지 추가
import useAuthStore from "../features/auth/stores/store"; // 경로 수정
import { hasTokens } from "../shared/utils/auth"; // 토큰 확인을 위해 추가

// ProtectedRoute 로직
interface ProtectedRouteProps {
  children: React.ReactNode;
}

const ProtectedRoute: React.FC<ProtectedRouteProps> = ({ children }) => {
  const { isAuthenticated, initAuth } = useAuthStore();
  const location = useLocation();
  const navigate = useNavigate();
  const [isChecking, setIsChecking] = useState(true);
  
  useEffect(() => {
    // 인증 상태 확인
    const checkAuth = async () => {
      console.log("ProtectedRoute - 인증 상태 확인 시작");
      
      // 스토어 상태가 준비되어 있지 않으면 초기화
      if (!isAuthenticated) {
        console.log("ProtectedRoute - 인증되지 않은 상태, 토큰 확인");
        // localStorage에서 토큰 확인
        if (hasTokens()) {
          console.log("ProtectedRoute - 토큰 존재, 인증 상태 초기화");
          await initAuth();
          setIsChecking(false);
        } else {
          console.log("ProtectedRoute - 토큰 없음, 로그인 페이지로 리다이렉트");
          navigate("/login", { state: { from: location }, replace: true });
        }
      } else {
        console.log("ProtectedRoute - 이미 인증된 상태");
        setIsChecking(false);
      }
    };
    
    checkAuth();
  }, [isAuthenticated, initAuth, navigate, location]);
  
  // 인증 상태 확인 중일 때는 로딩 상태 표시
  if (isChecking) {
    return <div className="loading-container">인증 확인 중...</div>;
  }
  
  // 최종 인증 확인 후 렌더링
  if (!isAuthenticated && !hasTokens()) {
    console.log("최종 확인 - 인증 안 됨");
    return <Navigate to="/login" state={{ from: location }} replace />;
  }
  
  console.log("최종 확인 - 인증 성공, 컨텐츠 렌더링");
  return <>{children}</>;
};

// 라우터 컴포넌트
const AppRouter: React.FC = () => {
  const { isAuthenticated, initAuth } = useAuthStore();
  const [authChecked, setAuthChecked] = useState(false);
  
  // 컴포넌트 마운트 시 인증 상태 확인
  useEffect(() => {
    console.log("AppRouter 마운트 - 인증 상태 확인");
    // 인증 상태 초기화 후 확인 완료 설정
    const checkAuth = async () => {
      await initAuth();
      setAuthChecked(true);
      console.log("인증 상태 확인 완료:", isAuthenticated ? "인증됨" : "인증 안됨");
    };
    
    checkAuth();
  }, [initAuth, isAuthenticated]);
  
  // 인증 확인 전에는 로딩 화면 표시
  if (!authChecked) {
    return <div className="loading-container">앱 로딩 중...</div>;
  }
  
  console.log("AppRouter 렌더링, 인증 상태:", isAuthenticated);

  return (
    <Routes>
      {/* 로그인 및 회원가입 라우트 */}
      <Route path="/login" element={<LoginPage />} />
      <Route path="/register" element={<RegisterPage />} />
      
      {/* 보호된 라우트 - 인증 필요한 페이지들 */}
      <Route
        path="/dashboard"
        element={
          <ProtectedRoute>
            <DashboardPage />
          </ProtectedRoute>
        }
      />
      
      <Route
        path="/project-management"
        element={
          <ProtectedRoute>
            <ProjectManagementPage />
          </ProtectedRoute>
        }
      />
      
      <Route
        path="/product-registration"
        element={
          <ProtectedRoute>
            <ProductRegistrationPage />
          </ProtectedRoute>
        }
      />
      
      <Route
        path="/funding-reports"
        element={
          <ProtectedRoute>
            <FundingReportsPage />
          </ProtectedRoute>
        }
      />
      
      {/* 루트 경로는 항상 로그인 페이지로 리다이렉트 */}
      <Route path="/" element={<Navigate to="/login" replace />} />
      
      {/* 기본 리다이렉트 - 일치하는 라우트가 없을 경우 */}
      <Route path="*" element={<Navigate to="/login" replace />} />
    </Routes>
  );
};

export default AppRouter;
