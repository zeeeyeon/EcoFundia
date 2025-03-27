import { create } from 'zustand';
import * as authApi from "../api/auth";

interface User {
  id: string;
  email: string;
  role: string;
}

interface AuthState {
  isAuthenticated: boolean;
  user: User | null;
  accessToken: string | null;
  refreshToken: string | null;
  login: (data: { user: User; accessToken: string; refreshToken: string }) => void;
  logout: () => void;
}

const useAuthStore = create<AuthState>()((set) => ({
  isAuthenticated: false,
  user: null,
  accessToken: null,
  refreshToken: null,
  login: (data: { user: User; accessToken: string; refreshToken: string }) => {
    set({
      isAuthenticated: true,
      user: data.user,
      accessToken: data.accessToken,
      refreshToken: data.refreshToken,
    });
  },
  logout: () => {
    // 세션 스토리지에서 토큰 제거
    sessionStorage.removeItem('accessToken');
    sessionStorage.removeItem('refreshToken');

    set({
      isAuthenticated: false,
      user: null,
      accessToken: null,
      refreshToken: null,
    });
  },
}));

export default useAuthStore;
