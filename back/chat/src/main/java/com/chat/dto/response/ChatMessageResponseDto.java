package com.chat.dto.response;

import com.chat.entity.Sender;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;

import java.time.LocalDateTime;

@Data
@Builder
@AllArgsConstructor
public class ChatMessageResponseDto {

    private String id;
    private int fundingId;
    private int senderId;
    private String nickname;
    private String content;
    private LocalDateTime createdAt;

}
