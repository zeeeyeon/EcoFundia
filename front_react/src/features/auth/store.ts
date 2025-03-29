import { create } from "zustand";
import { removeTokens, setTokens } from "../../shared/utils/auth";
import { googleLogin, registerSeller as apiRegisterSeller } from "./api/authService";

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
}));

export default useAuthStore; 