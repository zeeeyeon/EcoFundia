import { defineConfig } from "vite";
import react from "@vitejs/plugin-react-swc";

// https://vite.dev/config/
export default defineConfig({
  plugins: [react()],
  css: {
    postcss: "./postcss.config.cjs", // 혹은 자동 인식되면 생략 가능
  },
  server: {
    port: 59343,
    proxy: {
      "/api": {
        target: "https://j12e206.p.ssafy.io",
        changeOrigin: true,
        secure: false,
      },
    },
  },
});
