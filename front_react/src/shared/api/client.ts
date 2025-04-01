import axios from "axios";
import { getTokens } from "../../shared/utils/auth";
import useAuthStore from "../../features/auth/stores/store"; // 경로 수정

// API 기본 URL 설정
const BASE_URL =
  import.meta.env.VITE_API_BASE_URL || "https://j12e206.p.ssafy.io/api";

// Axios 인스턴스 생성
const client = axios.create({
  baseURL: BASE_URL,
  timeout: 10000,
  headers: {
    "Content-Type": "application/json",
  },
});

// 응답 인터셉터 추가 - 디버깅 목적
client.interceptors.response.use(
  (response) => {
    // 응답 로깅
    console.log(
      `API 응답 [${response.config.method?.toUpperCase()}] ${
        response.config.url
      }:`,
      {
        status: response.status,
        data: response.data,
      }
    );
    return response;
  },
  (error) => {
    console.error("API 에러:", {
      url: error.config?.url,
      method: error.config?.method,
      status: error.response?.status,
      data: error.response?.data,
    });
    return Promise.reject(error);
  }
);

// 요청 인터셉터 - 토큰 추가
client.interceptors.request.use(
  (config) => {
    // 원래 코드처럼 getTokens를 사용하여 토큰 관리 유지
    const tokens = getTokens();
    if (tokens?.accessToken) {
      config.headers = {
        ...config.headers,
        Authorization: `Bearer ${tokens.accessToken}`,
      };
    }

    // 요청 로깅
    console.log(`API 요청 [${config.method?.toUpperCase()}] ${config.url}:`, {
      params: config.params,
      data: config.data,
    });

    return config;
  },
  (error) => {
    console.error("API 요청 에러:", error);
    return Promise.reject(error);
  }
);

// 응답 인터셉터
client.interceptors.response.use(
  (response) => response,
  async (error) => {
    const originalRequest = error.config;

    // 401 에러이고 토큰이 만료된 경우
    if (error.response?.status === 401 && !originalRequest._retry) {
      originalRequest._retry = true;

      const tokens = getTokens();
      if (!tokens?.refreshToken) {
        useAuthStore.getState().resetAuthState();
        window.location.href = "/";
        return Promise.reject(error);
      }

      try {
        // 리프레시 토큰으로 새로운 액세스 토큰 요청
        // 주의: client 인스턴스를 사용하여 refresh 요청을 보내면 인터셉터가 무한 루프에 빠질 수 있습니다.
        // 별도의 axios 인스턴스를 사용하거나, 인터셉터 로직에서 refresh 요청을 제외해야 합니다.
        // 우선 현재 로직 유지, 추후 문제 발생 시 수정 필요
        const response = await client.post("/auth/refresh", {
          refreshToken: tokens.refreshToken,
        });

        const { accessToken } = response.data as { accessToken: string };

        // 새 토큰 저장
        const newTokens = { ...tokens, accessToken };
        // setTokens 유틸리티 함수 사용 권장
        sessionStorage.setItem("accessToken", newTokens.accessToken);
        // sessionStorage.setItem("refreshToken", newTokens.refreshToken); // 리프레시 토큰은 변경되지 않음

        // 원래 요청 재시도
        originalRequest.headers.Authorization = `Bearer ${accessToken}`;
        return client(originalRequest);
      } catch {
        useAuthStore.getState().resetAuthState();
        window.location.href = "/";
      }
    }

    return Promise.reject(error);
  }
);

export default client;
