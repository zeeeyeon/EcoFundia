import React, { useState, useEffect } from "react";
import { NavLink, useLocation } from "react-router-dom";
import "./layout.css";

// 아이콘 임포트 (예시 - 실제 아이콘 라이브러리 사용 권장)
const DashboardIcon = () => <span className="menu-icon">📊</span>;
const ProductsIcon = () => <span className="menu-icon">📦</span>;
const SettingsIcon = () => <span className="menu-icon">⚙️</span>;
const AddProductIcon = () => <span className="menu-icon">➕</span>;
const MoneyIcon = () => <span className="menu-icon">💰</span>;

interface SidebarProps {
  isOpen: boolean;
  toggleSidebar: () => void;
}

const Sidebar: React.FC<SidebarProps> = ({ isOpen, toggleSidebar }) => {
  const location = useLocation();
  const [showProductSubmenu, setShowProductSubmenu] = useState(false);

  // 현재 경로가 상품 관리 관련 경로인지 확인
  const isProductManagementActive = location.pathname.includes(
    "/project-management"
  );
  const isProductRegistrationActive = location.pathname.includes(
    "/product-registration"
  );
  const isProductSection =
    isProductManagementActive || isProductRegistrationActive;

  // 페이지 로드 시 및 경로 변경 시 상품 관리 메뉴 상태 조정
  useEffect(() => {
    if (isProductSection) {
      setShowProductSubmenu(true);
    }
  }, [isProductSection, location.pathname]);

  // 상품 관리 메뉴 클릭 핸들러
  const handleProductMenuClick = () => {
    // 링크 자체의 동작은 그대로 두고, 서브메뉴 상태만 토글
    setShowProductSubmenu(!showProductSubmenu);
  };

  return (
    <aside className={`dashboard-sidebar ${isOpen ? "open" : "closed"}`}>
      <button onClick={toggleSidebar} className="sidebar-toggle-button">
        {isOpen ? "◀" : "▶"}
      </button>
      <nav className="sidebar-nav">
        <ul>
          <li>
            <NavLink
              to="/dashboard"
              className={({ isActive }) => (isActive ? "active" : "")}
            >
              <DashboardIcon />
              {isOpen && <span className="menu-text">대시보드</span>}
            </NavLink>
          </li>

          {/* 상품 관리 메뉴 그룹 */}
          <li className={isProductSection ? "active-menu" : ""}>
            {/* 상품 관리 메인 메뉴 */}
            <NavLink
              to="/project-management"
              className={({ isActive }) => (isActive ? "active" : "")}
              onClick={handleProductMenuClick}
            >
              <ProductsIcon />
              {isOpen && <span className="menu-text">상품 관리</span>}
            </NavLink>

            {/* 서브메뉴 - 상품 관리 메뉴가 활성화되었을 때만 표시 */}
            {isOpen && showProductSubmenu && isProductSection && (
              <div className="submenu-container">
                <ul className="submenu">
                  <li>
                    <NavLink
                      to="/product-registration"
                      className={({ isActive }) => (isActive ? "active" : "")}
                    >
                      <AddProductIcon />
                      <span className="menu-text">상품 등록</span>
                    </NavLink>
                  </li>
                </ul>
              </div>
            )}
          </li>

          <li>
            <NavLink
              to="/funding-reports"
              className={({ isActive }) => (isActive ? "active" : "")}
            >
              <MoneyIcon />
              {isOpen && <span className="menu-text">정산 내역</span>}
            </NavLink>
          </li>

          <li>
            <NavLink
              to="/settings"
              className={({ isActive }) => (isActive ? "active" : "")}
            >
              <SettingsIcon />
              {isOpen && <span className="menu-text">설정</span>}
            </NavLink>
          </li>
        </ul>
      </nav>
    </aside>
  );
};

export default Sidebar;
