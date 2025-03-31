package com.chat.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.springframework.data.annotation.Id;
import org.springframework.data.mongodb.core.mapping.Document;

import java.time.LocalDateTime;

@Builder
@Document(collation = "chat_messages")
public class ChatMessageDocument {

    @Id
    private String id;
    private int fundingId;
    private Sender sender;
    private String content;
    private String status;
    private LocalDateTime createdAt;

    @Data
    @AllArgsConstructor
    @NoArgsConstructor
    public static class Sender {
        private int userId;
        private String nickname;
    }

    public static ChatMessageDocument toDto(ChatMessageDto chatMessageDto) {
        Sender sender = new Sender(chatMessageDto.senderId(), chatMessageDto.nickname());

        return ChatMessageDocument.builder()
                .fundingId(chatMessageDto.fundingId())
                .sender(sender)
                .content(chatMessageDto.content())
                .status(chatMessageDto.status())
                .createdAt(chatMessageDto.createdAt())
                .build();
    }
}
