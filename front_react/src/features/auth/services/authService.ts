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

// API 명세서에 맞춘 응답 형식 정의
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
    console.log("구글 토큰으로 로그인 시도:", token.substring(0, 15) + "...");

    const response = await client.post<LoginResponse>("/user/login", {
      token: token,
    });

    // 응답 상세 로깅 추가
    console.log("Google 로그인 응답 코드:", response.data.status.code);
    console.log("Google 로그인 응답 메시지:", response.data.status.message);

    // API 응답 코드 확인
    if (response.data.status.code !== 200) {
      console.error("로그인 실패 - 상태 코드:", response.data.status.code);
      throw new Error(response.data.status.message || "로그인에 실패했습니다.");
    }

    // content가 null인 경우 (404 등) - 명세서의 두 번째 응답 케이스
    if (!response.data.content) {
      console.error("로그인 실패 - content null");
      throw new Error(
        response.data.status.message || "사용자 정보를 찾을 수 없습니다."
      );
    }

    // content에서 필요한 데이터 추출
    const { accessToken, refreshToken, user, role } = response.data.content;
    console.log("로그인 성공:", user.email, "역할:", role);

    // 토큰 저장
    try {
      console.log("토큰 저장 시작");
      setTokens({
        accessToken,
        refreshToken,
      });
      console.log("토큰 저장 완료:", { accessToken: accessToken.substring(0, 10) + "...", refreshToken: refreshToken.substring(0, 10) + "..." });

      // 사용자 정보와 역할 로컬 스토리지에 저장
      localStorage.setItem("user", JSON.stringify(user));
      console.log("사용자 정보 저장 완료");
      
      localStorage.setItem("role", role);
      console.log("역할 정보 저장 완료:", role);
      
      // 저장된 값 다시 확인
      const savedTokens = localStorage.getItem("accessToken");
      console.log("저장된 액세스 토큰 확인:", savedTokens ? "존재함" : "없음");
    } catch (storageError) {
      console.error("로컬 스토리지 저장 중 오류:", storageError);
    }

    return { user, role, accessToken, refreshToken };
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
    // 로그아웃 API 호출
    await client.post("/user/logout");
    console.log("로그아웃 성공");
  } catch (error) {
    console.error("로그아웃 중 오류 발생:", error);
  } finally {
    // 토큰 제거 및 로컬 스토리지 정리
    removeTokens();
    localStorage.removeItem("user");
    localStorage.removeItem("role");
  }
};
