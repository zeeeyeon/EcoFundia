package com.chat.dto.response;

import lombok.Data;

import java.time.LocalDateTime;

@Data
public class ChatPageResponseDto {

    private int chatId;
    private int fundingId;
    private String title;
    private String content;
    private LocalDateTime createdAt;

}

