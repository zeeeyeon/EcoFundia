import React from "react";
import { Navigate, Outlet } from "react-router-dom";
import useAuthStore from "../../features/auth/stores/store";
import { getTokens } from "../utils/auth";

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
    // TODO: 권한 부족 시 보여줄 페이지나 로직을 명확히 해야 함 (예: 권한 없음 페이지)
    return <Navigate to="/dashboard" replace />;
  }

  return <Outlet />;
};

export default PrivateRoute;
