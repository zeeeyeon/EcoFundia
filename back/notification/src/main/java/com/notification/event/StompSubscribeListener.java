package com.notification.event;

import com.notification.service.ChatRoomService;
import lombok.RequiredArgsConstructor;
import org.springframework.context.event.EventListener;
import org.springframework.messaging.simp.stomp.StompHeaderAccessor;
import org.springframework.stereotype.Component;
import org.springframework.web.socket.messaging.SessionSubscribeEvent;

@Component
@RequiredArgsConstructor
public class StompSubscribeListener {

    private final ChatRoomService chatRoomService;

    @EventListener
    public void handleSubscribeEvent(SessionSubscribeEvent event) {

        StompHeaderAccessor accessor = StompHeaderAccessor.wrap(event.getMessage());
        String destination = accessor.getDestination(); // 예시) sub/chat/1

        if (destination != null && destination.equals("/sub/chat/")) {
            int fundingId = Integer.parseInt(destination.substring("sub/chat/".length()));

            // 토픽 생성 시도
            chatRoomService.createChatRoomIfNotExists(fundingId);
        }
    }
}
