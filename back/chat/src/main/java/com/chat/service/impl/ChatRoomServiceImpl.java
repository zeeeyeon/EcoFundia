package com.chat.service.impl;

import com.chat.common.exception.CustomException;
import com.chat.common.response.ResponseCode;
import com.chat.dto.response.ChatRoomCreateResponse;
import com.chat.dto.response.ChatRoomSummaryResponse;
import com.chat.dto.reuqest.ChatRoomCreateRequest;
import com.chat.entity.ChatRoom;
import com.chat.repository.ChatRoomRepository;
import com.chat.service.ChatRoomService;
import lombok.RequiredArgsConstructor;
import org.springframework.data.mongodb.core.MongoTemplate;
import org.springframework.data.mongodb.core.query.Criteria;
import org.springframework.data.mongodb.core.query.Query;
import org.springframework.data.mongodb.core.query.Update;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.List;

@Service
@RequiredArgsConstructor
public class ChatRoomServiceImpl implements ChatRoomService {

    private final ChatRoomRepository chatRoomRepository;
    private final MongoTemplate mongoTemplate;

    @Override
    public ChatRoomCreateResponse createRoom(ChatRoomCreateRequest request){

        ChatRoom chatRoom = ChatRoom.builder()
                .fundingId(request.fundingId())
                .title(request.title())
                .participants(request.participants())
                .createdAt(LocalDateTime.now().plusHours(9))
                .lastMessage(null)
                .lastMessageAt(null)
                .build();

        ChatRoom saved = chatRoomRepository.save(chatRoom);

        return new ChatRoomCreateResponse(saved.getId(), true);
    }

    @Override
    public void addParticipantIfNotExists(int fundingId, int userId){
        Query query = new Query(Criteria.where("fundingId").is(fundingId));

        Update update = new Update().addToSet("participants", userId);

        mongoTemplate.updateFirst(query, update, ChatRoom.class);
    }

    @Override
    public List<ChatRoomSummaryResponse> findChatRoomByUserId(int userId) {
        Query query = new Query(
                Criteria.where("participants").in(userId) // participants 배열에 포함된 방 찾기
        );

        List<ChatRoom> chatRooms = mongoTemplate.find(query, ChatRoom.class);

        if (chatRooms.isEmpty()) {
            throw new CustomException(ResponseCode.NO_CHAT_ROOMS);
        }

        return chatRooms.stream()
                .map(room -> new ChatRoomSummaryResponse(
                        room.getId(),
                        room.getFundingId(),
                        room.getTitle(),
                        room.getLastMessage(),
                        room.getLastMessageAt()
                ))
                .toList();
    }

    @Override
    public void removeParticipant(int fundingId, int userId){
        Query query = new Query(Criteria.where("fundingId").is(fundingId));
        Update update = new Update().pull("participants", userId);

        mongoTemplate.updateFirst(query, update, ChatRoom.class);

    }

    @Override
    public void updateLastMessage(int fundingId, String message, LocalDateTime at) {
        Query query = new Query(Criteria.where("fundingId").is(fundingId));

        Update update = new Update()
                .set("lastMessage", message)
                .set("lastMessageAt", at);

        mongoTemplate.updateFirst(query, update, ChatRoom.class);
    }

}
