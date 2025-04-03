package com.notification.buffer;

import com.notification.dto.ChatMessageDto;
import org.springframework.stereotype.Component;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

@Component
public class ChatMessageBuffer {

    private final Map<Integer, List<ChatMessageDto>> buffer = new ConcurrentHashMap<>();

    public void addMessage(int fundingId, ChatMessageDto message) {
        buffer.computeIfAbsent(fundingId, k -> new ArrayList<>()).add(message);
    }

    public boolean isReadyToFlush(int fundingId) {
        return buffer.get(fundingId).size() >= 50;
    }

    public List<ChatMessageDto> getAndClearBuffer(int fundingId) {
        List<ChatMessageDto> messages = new ArrayList<>(buffer.get(fundingId));
        buffer.get(fundingId).clear();
        return messages;
    }
}
