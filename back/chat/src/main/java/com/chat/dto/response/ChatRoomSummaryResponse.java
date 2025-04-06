package com.chat.dto.response;

import java.time.LocalDateTime;

public record ChatRoomSummaryResponse (
        String chatRoomId,
        int fundingId,
        String title,
        String lastMessage,
        LocalDateTime lastMessageAt
)
{}
