interface TokenResponse {
    accessToken: string;
    refreshToken: string;
}

// 세션 스토리지에 토큰 저장
export const setTokens = (tokens: TokenResponse) => {
    sessionStorage.setItem("accessToken", tokens.accessToken);
    sessionStorage.setItem("refreshToken", tokens.refreshToken);
};

// 토큰 가져오기
export const getTokens = (): TokenResponse | null => {
    const accessToken = sessionStorage.getItem("accessToken");
    const refreshToken = sessionStorage.getItem("refreshToken");

    if (!accessToken || !refreshToken) return null;

    return { accessToken, refreshToken };
};

// 토큰 삭제
export const removeTokens = () => {
    sessionStorage.removeItem("accessToken");
    sessionStorage.removeItem("refreshToken");
};

// axios 인터셉터에서 사용할 헤더 생성
export const getAuthHeader = () => {
    const tokens = getTokens();
    return tokens ? { Authorization: `Bearer ${tokens.accessToken}` } : {};
}; 