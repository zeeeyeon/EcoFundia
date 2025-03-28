import axios from "axios";
import { getTokens } from "../utils/auth";
import useAuthStore from "../features/auth/stores/authStore";

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
        const response = await client.post("/auth/refresh", {
          refreshToken: tokens.refreshToken,
        });

        const { accessToken } = response.data as { accessToken: string };

        // 새 토큰 저장
        const newTokens = { ...tokens, accessToken };
        sessionStorage.setItem("tokens", JSON.stringify(newTokens));

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
