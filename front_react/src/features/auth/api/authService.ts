import client from "../../../shared/api/client"; // 수정된 경로
import { setTokens, removeTokens } from "../../../shared/utils/auth"; // 경로 확인 - 현재 올바름

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

interface LoginResponse {
    status: {
        code: number;
        message: string;
    };
    content: {
        accessToken: string;
        refreshToken: string;
        user: User;
        role: "USER" | "SELLER";
    } | null;
}

interface RegisterSellerRequest {
    name: string;
    businessNumber: string;
}

interface RegisterSellerResponse {
    status: {
        code: number;
        message: string;
    };
    content: null;
}

export const googleLogin = async (token: string) => {
    try {
        const response = await client.post<LoginResponse>("/user/login", {
            token: token,
        });

        // 상태 코드 확인
        if (response.data.status.code !== 200) {
            throw new Error(response.data.status.message || "로그인에 실패했습니다.");
        }

        if (response.data.content === null) {
            throw new Error("로그인 응답이 올바르지 않습니다.");
        }

        const {
            accessToken: serverToken,
            refreshToken,
            user,
            role,
        } = response.data.content;

        // 토큰 저장
        setTokens({
            accessToken: serverToken,
            refreshToken,
        });

        return { user, role, accessToken: serverToken, refreshToken };
    } catch (error) {
        console.error("Google login error:", error);
        throw error;
    }
};

export const registerSeller = async (data: RegisterSellerRequest) => {
    const response = await client.post<RegisterSellerResponse>(
        "/seller/role",
        data
    );

    // 201 상태 코드 확인
    if (response.data.status.code !== 201) {
        throw new Error(
            response.data.status.message || "판매자 등록에 실패했습니다."
        );
    }

    return response.data;
};

export const logout = async () => {
    try {
        // 로그아웃 API는 현재 필요 없음
        // await client.post("/auth/logout");
    } finally {
        removeTokens();
    }
}; 