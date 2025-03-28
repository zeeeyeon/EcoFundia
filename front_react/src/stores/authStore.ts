import { create } from "zustand";
import { removeTokens, setTokens } from "../utils/auth";
import { googleLogin, registerSeller as apiRegisterSeller } from "../api/auth";

interface User {
  userId: number;
  email: string;
  name: string;
  nickname?: string;
  gender?: string;
  age?: number;
  account?: string;
  ssafyUserKey?: string;
  createdAt: string;
}

interface AuthState {
  isAuthenticated: boolean;
  isLoading: boolean;
  user: User | null;
  role: "USER" | "SELLER" | null;
  loginWithGoogle: (token: string) => Promise<{
    user: User;
    role: "USER" | "SELLER";
    accessToken: string;
    refreshToken: string;
  }>;
  registerSeller: (
    businessName: string,
    businessNumber: string
  ) => Promise<void>;
  logout: () => Promise<void>;
  resetAuthState: () => void;
}

const useAuthStore = create<AuthState>()((set) => ({
  isAuthenticated: false,
  isLoading: false,
  user: null,
  role: null,

  loginWithGoogle: async (token: string) => {
    set({ isLoading: true });
    try {
      const response = await googleLogin(token);
      const { user, role, accessToken, refreshToken } = response;

      // 세션 스토리지에 토큰 저장
      setTokens({ accessToken, refreshToken });

      set({
        isAuthenticated: true,
        user,
        role,
        isLoading: false,
      });

      return response; // 호출자가 role을 확인할 수 있도록 응답 반환
    } catch (error) {
      set({ isLoading: false });
      throw error;
    }
  },

  registerSeller: async (businessName: string, businessNumber: string) => {
    set({ isLoading: true });
    try {
      await apiRegisterSeller({
        name: businessName,
        businessNumber: businessNumber,
      });
      // 판매자 등록 성공 후 토큰만 삭제
      removeTokens();
      set({
        isAuthenticated: false,
        user: null,
        role: null,
        isLoading: false,
      });
    } catch (error) {
      set({ isLoading: false });
      throw error;
    } finally {
      set({ isLoading: false });
    }
  },

  logout: async () => {
    set({ isLoading: true });
    try {
      // 로그아웃 API 호출은 생략 (필요한 경우 추가)
      useAuthStore.getState().resetAuthState();
    } finally {
      set({ isLoading: false });
    }
  },

  resetAuthState: () => {
    // 세션 스토리지에서 토큰 제거
    removeTokens();
    set({
      isAuthenticated: false,
      user: null,
      role: null,
    });
  },
}));

export default useAuthStore;
