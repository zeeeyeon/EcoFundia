package com.chat.dto.response;

public record ChatRoomCreateResponse(

        String chatRoomId,
        boolean isCreated
) {}
