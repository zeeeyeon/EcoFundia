package com.chat.dto;

import lombok.Data;

@Data
public class ChatMessageDto {

    private String content;
    private String sender;
    private String channelId;

    public ChatMessageDto(String content, String sender) {
        this.content = content;
        this.sender = sender;
    }
}
