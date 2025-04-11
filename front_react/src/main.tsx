import { StrictMode } from "react";
import { createRoot } from "react-dom/client";
import { GoogleOAuthProvider } from "@react-oauth/google";
import "./index.css";
import App from "./App.tsx";

// 환경 변수에서 웹 애플리케이션 클라이언트 ID를 사용합니다
const clientId = import.meta.env.VITE_GOOGLE_CLIENT_ID;

// 클라이언트 ID가 없을 경우 경고 메시지 출력
if (!clientId) {
  console.error(
    "Google 클라이언트 ID가 설정되지 않았습니다! .env.local 파일에 VITE_GOOGLE_CLIENT_ID를 설정해주세요."
  );
}

createRoot(document.getElementById("root")!).render(
  <StrictMode>
    <GoogleOAuthProvider clientId={clientId || ""}>
      <App />
    </GoogleOAuthProvider>
  </StrictMode>
);
