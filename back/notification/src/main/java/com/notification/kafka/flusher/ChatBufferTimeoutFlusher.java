package com.notification.kafka.flusher;

import com.notification.buffer.ChatMessageBuffer;
import com.notification.client.ChatClient;
import com.notification.dto.ChatMessageDto;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

import java.time.Duration;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;

@Slf4j
@Component
@RequiredArgsConstructor
public class ChatBufferTimeoutFlusher {

    private final ChatMessageBuffer buffer;
    private final ChatClient chatClient;

    /**
     * 1분마다 실행되며, 버퍼가 일정 시간 이상 유지된 경우 강제 저장 수행
     * - Kafka retention.ms (1시간) 도달 전에 flush 보장 목적
     */
    @Scheduled(fixedDelay = 60000) // 1분 간격
    public void flushIfStale() {
        Duration flushTimeout = Duration.ofMinutes(50); // Kafka TTL보다 여유 있게 설정

        LocalDateTime now = LocalDateTime.now();

        for (Map.Entry<Integer, LocalDateTime> entry : buffer.getBufferStartTimes().entrySet()) {
            int fundingId = entry.getKey();
            LocalDateTime startedAt = entry.getValue();

            // 버퍼 생성된 지 50분 이상 경과 시 강제 저장
            if (Duration.between(startedAt, now).compareTo(flushTimeout) >= 0) {
                List<ChatMessageDto> toFlush = buffer.getAndClearBuffer(fundingId);

                if (!toFlush.isEmpty()) {
                    try {
                        chatClient.storeMessages(fundingId, toFlush);
                        log.info("⏱ [버퍼 TTL 초과 저장] fundingId={}, count={}", fundingId, toFlush.size());
                    } catch (Exception e) {
                        log.error("❌ [버퍼 저장 실패] fundingId={}, error={}", fundingId, e.getMessage());

                        // rollback: 메시지 다시 버퍼에 복원
                        for (ChatMessageDto msg : toFlush) {
                            buffer.addMessage(fundingId, msg);
                        }
                    }
                }
            }
        }
    }
}
