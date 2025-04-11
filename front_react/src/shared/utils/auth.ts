interface TokenResponse {
    accessToken: string;
    refreshToken: string;
}

// 로컬 스토리지에 토큰 저장 (sessionStorage에서 localStorage로 변경)
export const setTokens = (tokens: TokenResponse) => {
    localStorage.setItem("accessToken", tokens.accessToken);
    localStorage.setItem("refreshToken", tokens.refreshToken);
};

// 토큰 가져오기 (sessionStorage에서 localStorage로 변경)
export const getTokens = (): TokenResponse | null => {
    const accessToken = localStorage.getItem("accessToken");
    const refreshToken = localStorage.getItem("refreshToken");

    if (!accessToken || !refreshToken) return null;

    return { accessToken, refreshToken };
};

// 토큰이 존재하는지 확인하는 함수 추가
export const hasTokens = (): boolean => {
    return !!getTokens();
};

// 토큰 삭제 (sessionStorage에서 localStorage로 변경)
export const removeTokens = () => {
    localStorage.removeItem("accessToken");
    localStorage.removeItem("refreshToken");
};

// axios 인터셉터에서 사용할 헤더 생성
export const getAuthHeader = () => {
    const tokens = getTokens();
    return tokens ? { Authorization: `Bearer ${tokens.accessToken}` } : {};
}; 