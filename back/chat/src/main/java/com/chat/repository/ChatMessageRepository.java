package com.chat.repository;

import com.chat.dto.ChatMessageDocument;
import org.bson.types.ObjectId;
import org.springframework.data.domain.Pageable;
import org.springframework.data.mongodb.repository.MongoRepository;
import org.springframework.data.mongodb.repository.Query;

import java.util.List;

public interface ChatMessageRepository extends MongoRepository<ChatMessageDocument, String> {

    // fundingId별로 조회, id < lastId 기준으로 페이징
    @Query("{ 'fundingId': ?0, '_id': { $lt: ?1 } }")
    List<ChatMessageDocument> findByFundingIdAndIdBefore(int fundingId, ObjectId lastId, Pageable pageable);

    // 최초 조회용 (lastId 없이)
    List<ChatMessageDocument> findByFundingIdOrderByIdDesc(int fundingId, Pageable pageable);

}
