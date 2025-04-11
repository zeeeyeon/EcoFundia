package com.chat.repository;

import com.chat.dto.ChatMessageDocument;
import org.springframework.data.domain.Pageable;
import org.springframework.data.mongodb.repository.MongoRepository;

import java.time.LocalDateTime;
import java.util.List;

public interface ChatMessageRepository extends MongoRepository<ChatMessageDocument, String> {

    /**
     * 특정 채팅방에서, 특정 시간 이전 메시지를 최신순으로 20개 조회
     */
    List<ChatMessageDocument> findByFundingIdAndCreatedAtLessThanOrderByCreatedAtDesc(
            int fundingId,
            LocalDateTime createdAt,
            Pageable pageable
    );

}
