package com.notification.service;

import com.notification.dto.response.ChatRoomSummaryResponse;

import java.util.List;

public interface ChatRoomService {

    void createChatRoomIfNotExists(int fundingId);

    List<ChatRoomSummaryResponse> getChatRoomsByUserId(int userId);
}
