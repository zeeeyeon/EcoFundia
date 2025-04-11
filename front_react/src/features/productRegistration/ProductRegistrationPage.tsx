import React, { useState } from "react";
import Header from "../../shared/components/Header";
import Sidebar from "../../shared/components/Sidebar";
import ProductRegistrationForm from "./components/ProductRegistrationForm";
import "./styles/ProductRegistration.css";
import "../../shared/components/layout.css";

const ProductRegistrationPage: React.FC = () => {
  const [isSidebarOpen, setIsSidebarOpen] = useState(true);
  const toggleSidebar = () => setIsSidebarOpen((prev) => !prev);

  return (
    <div className="dashboard-layout">
      <Header />
      <Sidebar isOpen={isSidebarOpen} toggleSidebar={toggleSidebar} />
      <main className={`main-content ${isSidebarOpen ? "sidebar-open" : ""}`}>
        <div className="dashboard-content-area">
          <h1 className="page-title">펀딩 상품 등록</h1>
          <ProductRegistrationForm />
        </div>
      </main>
    </div>
  );
};

export default ProductRegistrationPage;
