package com.chat.entity;

import lombok.Builder;
import lombok.Data;
import org.springframework.data.annotation.Id;
import org.springframework.data.mongodb.core.mapping.Document;
import org.springframework.data.mongodb.core.mapping.Field;

import java.time.LocalDateTime;
import java.util.List;

@Data
@Builder
@Document(collection = "chat_room")
public class ChatRoom {

    @Id
    private String id;

    @Field("fundingId")
    private int fundingId;
    private String title;
    private List<Integer> participants;
    private LocalDateTime createdAt;
    private String lastMessage;
    private LocalDateTime lastMessageAt;

}
