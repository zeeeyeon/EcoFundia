package com.chat.config;

import com.chat.handler.ChatWebSocketHandler;
import lombok.RequiredArgsConstructor;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.socket.config.annotation.*;

/**
 *  Spring에서 WebSocket 구성을 위한 클래스
 */

@Configuration
@EnableWebSocket
@RequiredArgsConstructor
public class WebSocketConfig implements WebSocketConfigurer {

    private final ChatWebSocketHandler chatWebSocketHandler;

    // WebSocket 연결을 위해서 Handler을 구성
    @Override
    public void registerWebSocketHandlers(WebSocketHandlerRegistry registry) {
        System.out.println("[+] 최초 WebSocket 연결을 위한 등록 Handler");
        registry
                // 클라이언트에서 웹 소켓 연결을 위해 "ws-stomp"라는 앤드포인트로 연결을 시도하면
                // ChatWebSocketHandler 클래스에서 이를 처리한다.
                .addHandler(chatWebSocketHandler, "chat-room")
                .setAllowedOrigins("*"); // 접속 시도하는 모든 도메인 IP에서 webSocket 연경을 허용
    }

}
