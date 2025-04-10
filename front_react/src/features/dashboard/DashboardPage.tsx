import React, { useState, useEffect, useCallback } from "react";
import {
  LineChart,
  Line,
  XAxis,
  YAxis,
  CartesianGrid,
  Tooltip,
  ResponsiveContainer,
} from "recharts";
import Header from "../../shared/components/Header";
import Sidebar from "../../shared/components/Sidebar";
import StatCard from "./components/StatCard";
import AgeGroupChart from "./components/AgeGroupChart";
import TodayFundingList from "./components/TodayFundingList";
import ProductList from "./components/ProductList";
import useDashboardStore from "./stores/store";
import { ProductModal } from "../product";
import "./styles/dashboard.css";
import "../../shared/components/layout.css";
import "./styles/DashboardLayout.css";
import "../../shared/styles/common.css";
import { FaCoins, FaBoxOpen, FaClipboardList } from "react-icons/fa";
import { useNavigate } from "react-router-dom";
import useAuthStore from "../../features/auth/stores/store";
import { hasTokens } from "../../shared/utils/auth";

const DashboardPage: React.FC = () => {
  const [isSidebarOpen, setIsSidebarOpen] = useState(true);
  const {
    stats,
    fundingData,
    ageGroupData,
    todayFundingData,
    products,
    isLoading,
    error,
    fetchDashboardData,
  } = useDashboardStore();
  const navigate = useNavigate();
  const { isAuthenticated } = useAuthStore();

  // 인증 오류만 처리하는 함수 - useCallback으로 메모이제이션
  const handleAuthError = useCallback((error: Error) => {
    console.error("대시보드 데이터 로드 오류:", error);
    
    // 인증 오류인 경우 로그인 페이지로 이동
    if (error.message === "인증 오류" || error.message === "토큰이 없습니다. 로그인이 필요합니다.") {
      setTimeout(() => {
        navigate("/login", { replace: true });
      }, 2000);
    }
  }, [navigate]);

  useEffect(() => {
    try {
      fetchDashboardData().catch(error => handleAuthError(error));
    } catch (error) {
      handleAuthError(error as Error);
    }
  }, [fetchDashboardData, handleAuthError]);

  // 인증 상태 확인
  useEffect(() => {
    // 인증 상태나 토큰이 없으면 로그인 페이지로 이동
    if (!isAuthenticated && !hasTokens()) {
      console.log("대시보드 - 인증되지 않음, 로그인 페이지로 리다이렉트");
      navigate("/login", { replace: true });
    }
  }, [isAuthenticated, navigate]);

  // 디버깅용 로그 추가
  useEffect(() => {
    console.log("Dashboard Data State:", {
      stats,
      fundingData,
      ageGroupData,
      todayFundingData,
      products,
      isLoading,
      error,
    });
  }, [
    stats,
    fundingData,
    ageGroupData,
    todayFundingData,
    products,
    isLoading,
    error,
  ]);

  const toggleSidebar = () => {
    setIsSidebarOpen(!isSidebarOpen);
  };

  const formatYAxis = (tickItem: number) => {
    if (tickItem >= 100000000) {
      return `${(tickItem / 100000000).toLocaleString()}억`;
    } else if (tickItem >= 10000) {
      return `${(tickItem / 10000).toLocaleString()}만`;
    }
    return tickItem.toLocaleString();
  };

  const renderContent = () => {
    if (isLoading) {
      return <div className="loading-container">로딩 중...</div>;
    }
    if (error) {
      return (
        <div className="global-error-container">
          <div className="global-error-message">
            <h3>대시보드 오류</h3>
            <p>{error}</p>
            <button 
              className="global-error-close" 
              onClick={() => fetchDashboardData()}
            >
              확인
            </button>
          </div>
        </div>
      );
    }
    if (!stats) {
      return (
        <div className="no-data-message">
          대시보드 데이터를 불러올 수 없습니다.
        </div>
      );
    }

    // 디버깅용 데이터 검증
    const hasFundingData = fundingData && fundingData.length > 0;
    const hasAgeGroupData = ageGroupData && ageGroupData.length > 0;

    console.log("Chart Data Check:", {
      hasFundingData,
      hasAgeGroupData,
      fundingDataLength: fundingData.length,
      ageGroupDataLength: ageGroupData.length,
      fundingDataSample: hasFundingData ? fundingData[0] : null,
      ageGroupDataSample: hasAgeGroupData ? ageGroupData[0] : null,
    });

    return (
      <>
        <div className="stats-container">
          <StatCard
            title="총 펀딩 금액"
            value={stats.totalFunding}
            unit="원"
            icon={<FaCoins />}
          />
          <StatCard
            title="진행 중 상품"
            value={stats.ongoingProducts}
            unit="개"
            icon={<FaBoxOpen />}
          />
          <StatCard
            title="오늘 주문 수"
            value={stats.todayOrders}
            unit="건"
            icon={<FaClipboardList />}
          />
        </div>

        <div className="dashboard-row" style={{ height: "380px" }}>
          <div className="dashboard-section dashboard-card-50">
            <h3 className="section-title">월별 펀딩 금액</h3>
            <div
              className="chart-wrapper"
              style={{ height: "calc(100% - 40px)" }}
            >
              <div
                className="card-common"
                style={{
                  display: "flex",
                  alignItems: "center",
                  justifyContent: "center",
                  height: "100%",
                  width: "100%",
                  position: "relative",
                  overflow: "hidden",
                }}
              >
                {hasFundingData ? (
                  <div className="monthly-chart-container">
                    <ResponsiveContainer
                      width="100%"
                      height="100%"
                      minHeight={250}
                    >
                      <LineChart
                        data={fundingData}
                        margin={{ top: 15, right: 30, left: 30, bottom: 15 }}
                      >
                        <CartesianGrid strokeDasharray="3 3" vertical={false} />
                        <XAxis
                          dataKey="name"
                          tickLine={false}
                          axisLine={false}
                          tickMargin={15}
                          dy={5}
                          padding={{ left: 30, right: 30 }}
                        />
                        <YAxis
                          tickLine={false}
                          axisLine={false}
                          tickFormatter={formatYAxis}
                          width={40}
                        />
                        <Tooltip
                          formatter={(value: number) =>
                            `${value.toLocaleString()}원`
                          }
                          isAnimationActive={false}
                        />
                        <Line
                          type="monotone"
                          dataKey="value"
                          stroke="#8BC34A"
                          strokeWidth={3}
                          dot={{ r: 4 }}
                          activeDot={{ r: 6 }}
                          name="펀딩 금액"
                          isAnimationActive={false}
                        />
                      </LineChart>
                    </ResponsiveContainer>
                  </div>
                ) : (
                  <div className="no-data-message">
                    월별 펀딩 데이터가 없습니다.
                  </div>
                )}
              </div>
            </div>
          </div>
          <div className="dashboard-section dashboard-card-50">
            <h3 className="section-title">연령대별 통계</h3>
            <div
              className="chart-wrapper"
              style={{ height: "calc(100% - 40px)" }}
            >
              <div className="monthly-chart-container">
                <AgeGroupChart data={ageGroupData} />
              </div>
            </div>
          </div>
        </div>

        <div className="dashboard-row" style={{ height: "450px" }}>
          <div
            className="dashboard-section dashboard-card-60"
            style={{ height: "100%" }}
          >
            <h3 className="section-title">오늘의 펀딩</h3>
            <div
              className="chart-wrapper"
              style={{ height: "calc(100% - 40px)" }}
            >
              <TodayFundingList data={todayFundingData} />
            </div>
          </div>
          <div
            className="dashboard-section dashboard-card-40"
            style={{ height: "100%" }}
          >
            <h3 className="section-title">나의 베스트 상품 Top 5</h3>
            <div
              className="chart-wrapper"
              style={{ height: "calc(100% - 40px)" }}
            >
              <div className="product-list-wrapper">
                {products && products.length > 0 ? (
                  <ProductList products={products} />
                ) : (
                  <div className="no-data-message">
                    진행 중인 제품이 없습니다.
                  </div>
                )}
              </div>
            </div>
          </div>
        </div>
      </>
    );
  };

  return (
    <div className="dashboard-layout">
      <Header />
      <Sidebar isOpen={isSidebarOpen} toggleSidebar={toggleSidebar} />
      <main
        className={`main-content ${
          isSidebarOpen ? "sidebar-open" : "sidebar-closed"
        }`}
      >
        <div className="dashboard-content-area">
          <h1>대시보드</h1>
          {renderContent()}
        </div>
      </main>
      <ProductModal />
    </div>
  );
};

export default DashboardPage;
