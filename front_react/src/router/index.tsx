import React from 'react';
import { Routes, Route, Navigate, useLocation } from 'react-router-dom';
import LoginPage from '../features/auth/LoginPage'; // 경로 수정
import RegisterPage from '../features/register/RegisterPage'; // 경로 수정 및 이름 변경
import DashboardPage from '../features/dashboard/DashboardPage'; // 경로 수정
import useAuthStore from '../features/auth/store'; // 경로 수정

// ProtectedRoute 로직
interface ProtectedRouteProps {
    children: React.ReactNode;
}

const ProtectedRoute: React.FC<ProtectedRouteProps> = ({ children }) => {
    const { isAuthenticated } = useAuthStore();
    const location = useLocation();

    if (!isAuthenticated) {
        // 로그인 페이지로 리다이렉트 시 이전 경로 저장
        return <Navigate to="/login" state={{ from: location }} replace />;
    }

    return <>{children}</>;
};

// 라우터 컴포넌트
const AppRouter: React.FC = () => {
    const { isAuthenticated } = useAuthStore();

    return (
        <Routes>
            <Route path="/login" element={<LoginPage />} />
            <Route path="/register" element={<RegisterPage />} /> {/* 컴포넌트 이름 변경 */}
            <Route
                path="/dashboard"
                element={
                    <ProtectedRoute>
                        <DashboardPage />
                    </ProtectedRoute>
                }
            />
            {/* 루트 경로 처리: 인증 상태에 따라 리다이렉트 */}
            <Route
                path="/"
                element={isAuthenticated ? <Navigate to="/dashboard" replace /> : <Navigate to="/login" replace />}
            />
            {/* 필요한 경우 404 페이지 라우트 추가 */}
            {/* <Route path="*" element={<NotFoundPage />} /> */}
        </Routes>
    );
};

export default AppRouter; 