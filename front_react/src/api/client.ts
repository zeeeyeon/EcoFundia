import axios from "axios";
import { getAuthHeader, getTokens, removeTokens } from "../utils/auth";

const client = axios.create({
  baseURL: import.meta.env.VITE_API_URL || "http://localhost:8080",
  headers: {
    "Content-Type": "application/json",
  },
});

// 요청 인터셉터
client.interceptors.request.use(
  (config) => {
    const headers = getAuthHeader();
    if (headers.Authorization) {
      config.headers.Authorization = headers.Authorization;
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
        removeTokens();
        window.location.href = "/login";
        return Promise.reject(error);
      }

      try {
        // 리프레시 토큰으로 새로운 액세스 토큰 요청
        const response = await client.post("/auth/refresh", {
          refreshToken: tokens.refreshToken,
        });

        if (response.data.accessToken) {
          originalRequest.headers.Authorization = `Bearer ${response.data.accessToken}`;
          return client(originalRequest);
        }
      } catch (refreshError) {
        removeTokens();
        window.location.href = "/login";
      }
    }

    return Promise.reject(error);
  }
);

export default client;
