package com.chat.repository;

import com.chat.dto.ChatMessageDocument;
import org.springframework.data.mongodb.repository.MongoRepository;

import java.util.List;

public interface ChatMessageRepository extends MongoRepository<ChatMessageDocument, String> {

    List<ChatMessageDocument> findByFundingIdOrderByCreatedAtAsc(int fundingId);

}
