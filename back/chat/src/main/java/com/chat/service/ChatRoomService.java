package com.chat.service;

import com.chat.dto.response.ChatRoomCreateResponse;
import com.chat.dto.response.ChatRoomSummaryResponse;
import com.chat.dto.reuqest.ChatRoomCreateRequest;

import java.time.LocalDateTime;
import java.util.List;

public interface ChatRoomService {

    ChatRoomCreateResponse createRoom(ChatRoomCreateRequest request);

    void addParticipantIfNotExists(int fundingId, int userId);

    List<ChatRoomSummaryResponse> findChatRoomByUserId(int userId);

    void removeParticipant(int fundingId, int userId);

    void updateLastMessage(int fundingId, String message, LocalDateTime at);

}
