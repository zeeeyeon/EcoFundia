import React from 'react';
import { NavLink } from 'react-router-dom';
import './layout.css';

// 아이콘 임포트 (예시 - 실제 아이콘 라이브러리 사용 권장)
const DashboardIcon = () => <span>📊</span>;
const ProductsIcon = () => <span>📦</span>;
const SettingsIcon = () => <span>⚙️</span>;
const AddProductIcon = () => <span>➕</span>;

interface SidebarProps {
    isOpen: boolean;
    toggleSidebar: () => void;
}

const Sidebar: React.FC<SidebarProps> = ({ isOpen, toggleSidebar }) => {
    return (
        <aside className={`dashboard-sidebar ${isOpen ? 'open' : 'closed'}`}>
            <button onClick={toggleSidebar} className="sidebar-toggle-button">
                {isOpen ? '◀' : '▶'}
            </button>
            <nav className="sidebar-nav">
                <ul>
                    <li>
                        <NavLink
                            to="/dashboard"
                            className={({ isActive }) => isActive ? 'active' : ''}
                        >
                            <DashboardIcon />
                            {isOpen && <span className="menu-text">대시보드</span>}
                        </NavLink>
                    </li>
                    <li>
                        <NavLink
                            to="/project-management"
                            className={({ isActive }) => isActive ? 'active' : ''}
                        >
                            <ProductsIcon />
                            {isOpen && <span className="menu-text">상품 관리</span>}
                        </NavLink>
                    </li>
                    <li>
                        <NavLink
                            to="/product-registration"
                            className={({ isActive }) => isActive ? 'active' : ''}
                        >
                            <AddProductIcon />
                            {isOpen && <span className="menu-text">상품 등록</span>}
                        </NavLink>
                    </li>
                    <li>
                        <NavLink
                            to="/settings"
                            className={({ isActive }) => isActive ? 'active' : ''}
                        >
                            <SettingsIcon />
                            {isOpen && <span className="menu-text">설정</span>}
                        </NavLink>
                    </li>
                    {/* 다른 메뉴 항목 추가 */}
                </ul>
            </nav>
        </aside>
    );
};

export default Sidebar; 