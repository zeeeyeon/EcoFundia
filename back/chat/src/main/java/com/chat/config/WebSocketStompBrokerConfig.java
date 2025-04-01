package com.chat.config;

import org.springframework.context.annotation.Configuration;
import org.springframework.messaging.simp.config.MessageBrokerRegistry;
import org.springframework.web.socket.config.annotation.EnableWebSocketMessageBroker;
import org.springframework.web.socket.config.annotation.StompEndpointRegistry;
import org.springframework.web.socket.config.annotation.WebSocketMessageBrokerConfigurer;

/**
 * STOMP를 사용하여 메시지 브로커를 설정
 * WebSocket 메시지 브로커의 설정을 정의하는 메서드를 제공,
 * 이를 통해 메시지 브로커를 구성하고 STOMP 엔트포인트를 등록할 수 있음
 */

@Configuration
@EnableWebSocketMessageBroker
public class WebSocketStompBrokerConfig implements WebSocketMessageBrokerConfigurer {

    /**
     * configureMessageBroker(): 메시지 브로커 옵션을 구성합니다.
     */
    @Override
    public void configureMessageBroker(MessageBrokerRegistry config) {
        // 구독(sub) : 접두사로 시작하는 메시지를 브로커가 처리하도록 설정
        //            클라이언트는 이 접두사로 시작하는 주제를 구독하여 메시지를 받음
        // 예) 소켓 통신에서 사용자가 특정 메시지를 받기 위해 "/sub" 이라는 prefix 기반 메시지 수신을 위해 Subscribe 함
        config.enableSimpleBroker("/sub");

        // 발행(pub) : 접두사로 시작하는 메시지는 @MessageMapping이 달린 메서드로 라우팅됩니다.
        // 예) 소켓 통신에서 사용자가 특정 메시지를 전송하게 위해 "/pub"라는 prefix 기반 메시지 전송을 위해 Publish 합니다.
        config.setApplicationDestinationPrefixes("/pub");
    }

    /**
     * registerStompEndpoints() : 각각 특정 URL에 매핑되는 STOMP 엔드포인트를 등록하고
     *                            선택적으로 SockJS 플백 옵션을 활성화하고 구성
     */
    @Override
    public void registerStompEndpoints(StompEndpointRegistry registry) {
        // addEndpoint : 클라이언트가 WebSocket에 연결하기 위한 엔드포인트를 "/ws-stomp"로 설정
        // withSockJS : WebSocket을 지원하지 않는 브라우저에서도 SocketJS를 통해 WebSocket 기능을 사용할 수 있게 합니다.

        registry
                // 클라이언트가 WebSocket에 연결하기 위한 엔드포인트를 "/ws-stomp"로 설정합니다.
                .addEndpoint("/chat-room")
                // 클라이언트의 origin을 명시적으로 지정
                .setAllowedOrigins("http://localhost:3000", "http://localhost:3001")
                // WebSocket을 지원하지 않는 브라우저에서도 SockJS를 통해 WebSocket 기능을 사용
                .withSockJS();
    }

}
