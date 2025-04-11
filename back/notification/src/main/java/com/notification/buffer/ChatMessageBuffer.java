package com.notification.buffer;

import com.notification.dto.ChatMessageDto;
import org.springframework.stereotype.Component;

import java.time.LocalDateTime;
import java.util.*;
import java.util.concurrent.ConcurrentHashMap;

@Component
public class ChatMessageBuffer {

    // 채팅방별 메시지 버퍼
    private final Map<Integer, List<ChatMessageDto>> buffer = new ConcurrentHashMap<>();

    // 채팅방별 마지막 메시지 추가 시간 (즉시 flush 여부 판단용)
    private final Map<Integer, LocalDateTime> lastUpdateTime = new ConcurrentHashMap<>();

    // 채팅방별 최초 메시지 추가 시간 (지속적으로 오더라도 flush 조건 판단용)
    private final Map<Integer, LocalDateTime> bufferStartTime = new ConcurrentHashMap<>();

    /**
     * 메시지를 버퍼에 추가하고, 최초/최종 시간을 갱신한다.
     */
    public void addMessage(int fundingId, ChatMessageDto message) {
        buffer.computeIfAbsent(fundingId, k -> new ArrayList<>()).add(message);

        // 최초 메시지 시간은 한 번만 기록
        bufferStartTime.putIfAbsent(fundingId, LocalDateTime.now());

        // 마지막 메시지 시간은 항상 갱신
        lastUpdateTime.put(fundingId, LocalDateTime.now());
    }

    /**
     * 50개 이상이면 즉시 flush 조건 만족
     */
    public boolean isReadyToFlush(int fundingId) {
        return buffer.getOrDefault(fundingId, List.of()).size() >= 5;
    }

    /**
     * flush 시 버퍼에서 메시지를 꺼내고 정리
     */
    public List<ChatMessageDto> getAndClearBuffer(int fundingId) {
        List<ChatMessageDto> messages = new ArrayList<>(buffer.getOrDefault(fundingId, List.of()));
        buffer.remove(fundingId);
        lastUpdateTime.remove(fundingId);
        bufferStartTime.remove(fundingId);
        return messages;
    }

    /**
     * 아직 저장되지 않은 메시지 목록 반환 (WebSocket 입장 시 전송용)
     */
    public List<ChatMessageDto> getBufferedMessages(int fundingId) {
        return new ArrayList<>(buffer.getOrDefault(fundingId, List.of()));
    }

    /**
     * 채팅방별 마지막 메시지 시간 반환 (flush delay 기준용)
     */
    public Map<Integer, LocalDateTime> getLastUpdateTimes() {
        return new HashMap<>(lastUpdateTime);
    }

    /**
     * 채팅방별 버퍼 시작 시간 반환 (flush timeout 기준용)
     */
    public Map<Integer, LocalDateTime> getBufferStartTimes() {
        return new HashMap<>(bufferStartTime);
    }

    /**
     * 특정 채팅방의 버퍼 시작 시간 반환
     */
    public LocalDateTime getBufferStartTime(int fundingId) {
        return bufferStartTime.get(fundingId);
    }
}
