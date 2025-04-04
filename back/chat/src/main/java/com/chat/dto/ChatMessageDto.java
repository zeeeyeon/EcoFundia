package com.chat.dto;


import com.chat.entity.Sender;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;


@Data
@AllArgsConstructor
@NoArgsConstructor
public class ChatMessageDto {

    private int fundingId;
    private Sender sender;
    private String content;
    private String status;
    private LocalDateTime createdAt;

}

