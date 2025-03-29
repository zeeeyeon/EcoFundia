import React from 'react';
import { Link } from 'react-router-dom';
import Leaf from '../../assets/Leaf.svg'; // 경로 수정
import './layout.css'; // 이 파일도 shared로 이동 고려

const Header: React.FC = () => {
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
                <span className="user-greeting">안녕하세요, 판매자님!</span>
                <button className="logout-button">로그아웃</button>
            </div>
        </header>
    );
};

export default Header; 