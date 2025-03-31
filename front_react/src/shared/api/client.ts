import axios from "axios";
import { getTokens } from "../utils/auth"; // 경로 수정
import useAuthStore from "../../features/auth/stores/store"; // 경로 수정

export const client = axios.create({
  baseURL: "https://j12e206.p.ssafy.io/api",
  headers: {
    "Content-Type": "application/json",
  },
});

// 요청 인터셉터
client.interceptors.request.use(
  (config) => {
    const tokens = getTokens();
    if (tokens?.accessToken) {
      config.headers = {
        ...config.headers,
        Authorization: `Bearer ${tokens.accessToken}`,
      };
    }
    return config;
  },
  (error) => Promise.reject(error)
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
