package com.chat.dto;


import java.time.LocalDateTime;

public record ChatMessageDto(
    int fundingId,
    int senderId,
    String nickname,
    String content,
    String status, // ex: SENT, DELIVERED
    LocalDateTime createdAt
) {}

