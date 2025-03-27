import { create } from "zustand";
import * as authApi from "../api/auth";

interface User {
  id: string;
  email: string;
  role: "user" | "seller";
  nickname?: string;
  businessNumber?: string;
}

interface AuthState {
  user: User | null;
  isAuthenticated: boolean;
  isLoading: boolean;
  login: (email: string, password: string) => Promise<void>;
  registerSeller: (nickname: string, businessNumber: string) => Promise<void>;
  logout: () => Promise<void>;
  setUser: (user: User | null) => void;
}

const useAuthStore = create<AuthState>((set) => ({
  user: null,
  isAuthenticated: false,
  isLoading: false,

  login: async (email: string, password: string) => {
    set({ isLoading: true });
    try {
      const response = await authApi.login(email, password);
      if (response.user.role !== "seller") {
        throw new Error("판매자 권한이 없습니다.");
      }
      set({ user: response.user, isAuthenticated: true });
    } finally {
      set({ isLoading: false });
    }
  },

  registerSeller: async (nickname: string, businessNumber: string) => {
    set({ isLoading: true });
    try {
      const response = await authApi.registerSeller({
        nickname,
        businessNumber,
      });
      set({ user: response.user, isAuthenticated: true });
      // 회원가입 완료 후 자동 로그아웃
      await authApi.logout();
      set({ user: null, isAuthenticated: false });
    } finally {
      set({ isLoading: false });
    }
  },

  logout: async () => {
    set({ isLoading: true });
    try {
      await authApi.logout();
    } finally {
      set({ user: null, isAuthenticated: false, isLoading: false });
    }
  },

  setUser: (user: User | null) => {
    set({ user, isAuthenticated: !!user });
  },
}));

export default useAuthStore;
