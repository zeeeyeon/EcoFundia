package com.chat.dto.reuqest;


import com.chat.entity.Sender;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;


@Data
@AllArgsConstructor
@NoArgsConstructor
public class ChatMessageRequestDto {

    private int fundingId;
    private int senderId;
    private String nickname;
    private String content;
    private LocalDateTime createdAt;

}

