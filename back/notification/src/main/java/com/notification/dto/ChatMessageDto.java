package com.notification.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Builder
@Data
@AllArgsConstructor
@NoArgsConstructor
public class ChatMessageDto {

    private int fundingId;
    private int senderId;
    private String nickname;
    private String content;
    private LocalDateTime createdAt;
}
