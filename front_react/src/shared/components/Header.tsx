import React, { useEffect, useState } from 'react';
import { Link, useNavigate } from 'react-router-dom';
import Leaf from '../../assets/Leaf.svg'; // 경로 수정
import './layout.css'; // 이 파일도 shared로 이동 고려
import { logout } from '../../features/auth/api/authService';
import useAuthStore from '../../features/auth/store';

const Header: React.FC = () => {
    const navigate = useNavigate();
    const { user } = useAuthStore();
    const [userName, setUserName] = useState<string>('판매자');

    // 컴포넌트 마운트 시 사용자 정보 확인
    useEffect(() => {
        if (user && user.name) {
            setUserName(user.name);
        }
    }, [user]);

    const handleLogout = async () => {
        try {
            // authService의 logout 함수 호출
            await logout();
            // 로그인 페이지로 리다이렉트
            navigate('/login');
        } catch (error) {
            console.error('로그아웃 처리 중 오류 발생:', error);
            // 오류 발생 시에도 로그인 페이지로 이동
            navigate('/login');
        }
    };

    return (
        <header className="dashboard-header">
            <div className="header-left">
                <Link to="/dashboard" className="logo-link">
                    <img src={Leaf} alt="Eco Funding Logo" className="header-logo-icon" />
                    <span className="header-logo-text">EcoFunding</span>
                </Link>
            </div>
            <div className="header-right">
                {/* 알림 아이콘, 사용자 프로필 등 추가 가능 */}
                <span className="user-greeting">환영합니다, <span className="user-name">{userName}</span>님!</span>
                <button className="logout-button" onClick={handleLogout}>로그아웃</button>
            </div>
        </header>
    );
};

export default Header; 