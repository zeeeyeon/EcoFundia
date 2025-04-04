package com.chat.dto;

import com.chat.entity.Sender;
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



    public static ChatMessageDocument fromDto(ChatMessageDto chatMessageDto) {

        return ChatMessageDocument.builder()
                .fundingId(chatMessageDto.getFundingId())
                .sender(chatMessageDto.getSender())
                .content(chatMessageDto.getContent())
                .status(chatMessageDto.getStatus())
                .createdAt(chatMessageDto.getCreatedAt())
                .build();
    }

    public ChatMessageDto toDto() {
        return new ChatMessageDto(fundingId, sender, content, status, createdAt);
    }


}
