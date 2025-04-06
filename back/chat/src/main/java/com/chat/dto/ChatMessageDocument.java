package com.chat.dto;

import com.chat.dto.response.ChatMessageResponseDto;
import com.chat.dto.reuqest.ChatMessageRequestDto;
import com.chat.entity.Sender;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.springframework.data.annotation.Id;
import org.springframework.data.mongodb.core.mapping.Document;

import java.time.LocalDateTime;

@Builder
@Document(collection = "chat_messages")
public class ChatMessageDocument {

    @Id
    private String id;
    private int fundingId;
    private Sender sender;
    private String content;
    private LocalDateTime createdAt;



    public static ChatMessageDocument fromDto(ChatMessageRequestDto chatMessageDto) {
        Sender sender = new Sender(chatMessageDto.getSenderId(), chatMessageDto.getNickname());

        return ChatMessageDocument.builder()
                .fundingId(chatMessageDto.getFundingId())
                .sender(sender)
                .content(chatMessageDto.getContent())
                .createdAt(chatMessageDto.getCreatedAt().plusHours(9)) //UTC로 저장하기 때문에 9시간 더해버리기
                .build();
    }

    public ChatMessageResponseDto toDto() {
        return new ChatMessageResponseDto(id, fundingId, sender.getUserId(),sender.getNickname(), content, createdAt.plusHours(-9));
    }


}
