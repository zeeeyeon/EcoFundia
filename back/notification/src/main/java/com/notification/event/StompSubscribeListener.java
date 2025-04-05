package com.notification.event;

import com.notification.buffer.ChatMessageBuffer;
import com.notification.dto.ChatMessageDto;
import com.notification.service.ChatRoomService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.context.event.EventListener;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.messaging.simp.stomp.StompHeaderAccessor;
import org.springframework.stereotype.Component;
import org.springframework.web.socket.messaging.SessionSubscribeEvent;

import java.util.List;

@Slf4j
@Component
@RequiredArgsConstructor
public class StompSubscribeListener {

    private final ChatRoomService chatRoomService;
    private final SimpMessagingTemplate simpMessagingTemplate;
    private final ChatMessageBuffer chatMessageBuffer;

    @EventListener
    public void handleSubscribeEvent(SessionSubscribeEvent event) {

        StompHeaderAccessor accessor = StompHeaderAccessor.wrap(event.getMessage());
        String destination = accessor.getDestination(); // 예시) sub/chat/1

        if (destination != null && destination.startsWith("/sub/chat/")) {
            try {
                int fundingId = Integer.parseInt(destination.substring("/sub/chat/".length()));

                // 1. Kafka 토픽 생성
                chatRoomService.createChatRoomIfNotExists(fundingId);

                // 2. 버퍼에서 아직 저장되지 않은 메시지 조회 + 전송
                List<ChatMessageDto> bufferedMessages = chatMessageBuffer.getBufferedMessages(fundingId);
                if (!bufferedMessages.isEmpty()) {
                    for (ChatMessageDto message : bufferedMessages) {
                        simpMessagingTemplate.convertAndSend(destination, message);
                    }
                    log.info("📨 구독자에게 버퍼 메시지 전송: fundingId={}, count={}", fundingId, bufferedMessages.size());
                }

            } catch (NumberFormatException e) {
                log.warn("❌ 잘못된 채팅 destination 형식: {}", destination);
            }
        }
    }
}
