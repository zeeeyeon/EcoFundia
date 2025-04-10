import { create } from "zustand";
import { persist, createJSONStorage } from "zustand/middleware";
import { removeTokens, setTokens, getTokens } from "../../../shared/utils/auth";
import {
  googleLogin,
  registerSeller as apiRegisterSeller,
} from "../services/authService";

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
  initAuth: () => Promise<boolean>;
}

const useAuthStore = create<AuthState>()(
  persist(
    (set, get) => ({
      isAuthenticated: false,
      isLoading: false,
      user: null,
      role: null,

      loginWithGoogle: async (token: string) => {
        set({ isLoading: true });
        try {
          const response = await googleLogin(token);
          const { user, role, accessToken, refreshToken } = response;

          setTokens({ accessToken, refreshToken });

          set({
            isAuthenticated: true,
            user,
            role,
            isLoading: false,
          });

          return response;
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
          useAuthStore.getState().resetAuthState();
        } finally {
          set({ isLoading: false });
        }
      },

      resetAuthState: () => {
        removeTokens();
        set({
          isAuthenticated: false,
          user: null,
          role: null,
        });
      },

      initAuth: async () => {
        console.log("initAuth 함수 실행 시작");
        
        if (get().isAuthenticated && get().user) {
          console.log("이미 인증 상태가 persist로 복원됨:", get().user?.email);
          return true;
        }
        
        const tokens = getTokens();
        console.log("localStorage에서 가져온 토큰:", tokens ? "토큰 존재" : "토큰 없음");
        
        const userJson = localStorage.getItem("user");
        console.log("localStorage에서 가져온 사용자 정보:", userJson ? "사용자 정보 존재" : "사용자 정보 없음");
        
        const roleStr = localStorage.getItem("role");
        console.log("localStorage에서 가져온 역할 정보:", roleStr);
        
        await new Promise(resolve => setTimeout(resolve, 300));
        
        if (tokens && userJson) {
          try {
            const user = JSON.parse(userJson) as User;
            const role = roleStr as "USER" | "SELLER" | null;
            
            console.log("사용자 정보 파싱 성공:", user.email);
            console.log("역할 정보:", role);
            
            set({
              isAuthenticated: true,
              user,
              role,
            });
            
            console.log("인증 상태 복원 완료: isAuthenticated = true");
            return true;
          } catch (error) {
            console.error("저장된 사용자 정보 파싱 오류:", error);
            get().resetAuthState();
            return false;
          }
        } else {
          console.log("인증 정보가 부족하여 인증 상태를 설정하지 않음");
          return false;
        }
      }
    }),
    {
      name: "auth-storage",
      storage: createJSONStorage(() => localStorage),
      partialize: (state) => ({
        isAuthenticated: state.isAuthenticated,
        user: state.user,
        role: state.role,
      }),
    }
  )
);

export default useAuthStore;
