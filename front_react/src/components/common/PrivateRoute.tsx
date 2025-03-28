import React from "react";
import { Navigate, Outlet } from "react-router-dom";
import useAuthStore from "../../features/auth/stores/authStore";
import { getTokens } from "../../utils/auth";

interface PrivateRouteProps {
  requiredRole?: "USER" | "SELLER";
}

const PrivateRoute: React.FC<PrivateRouteProps> = ({ requiredRole }) => {
  const { isAuthenticated, role } = useAuthStore();
  const tokens = getTokens();

  if (!isAuthenticated || !tokens) {
    // 로그인되지 않은 경우 로그인 페이지로 리다이렉트
    return <Navigate to="/" replace />;
  }

  if (requiredRole && role !== requiredRole) {
    // 필요한 권한이 없는 경우 대시보드로 리다이렉트
    return <Navigate to="/dashboard" replace />;
  }

  return <Outlet />;
};

export default PrivateRoute;
