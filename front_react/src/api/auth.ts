import client from "./client";
import { setTokens, removeTokens } from "../utils/auth";

interface LoginResponse {
  accessToken: string;
  refreshToken: string;
  user: {
    id: string;
    email: string;
    role: "user" | "seller";
    nickname?: string;
    businessNumber?: string;
  };
}

interface RegisterSellerData {
  nickname: string;
  businessNumber: string;
}

export const login = async (email: string, password: string) => {
  const response = await client.post<LoginResponse>("/auth/login", {
    email,
    password,
  });

  setTokens({
    accessToken: response.data.accessToken,
    refreshToken: response.data.refreshToken,
  });

  return response.data;
};

export const registerSeller = async (data: RegisterSellerData) => {
  const response = await client.post<LoginResponse>(
    "/auth/register-seller",
    data
  );
  return response.data;
};

export const logout = async () => {
  try {
    await client.post("/auth/logout");
  } finally {
    removeTokens();
  }
};
