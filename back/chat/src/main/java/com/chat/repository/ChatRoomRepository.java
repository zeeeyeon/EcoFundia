package com.chat.repository;

import com.chat.entity.ChatRoom;
import org.springframework.data.mongodb.repository.MongoRepository;
import org.springframework.data.mongodb.repository.Query;
import org.springframework.data.mongodb.repository.Update;

import java.time.LocalDateTime;

public interface ChatRoomRepository extends MongoRepository<ChatRoom, String> {
}
