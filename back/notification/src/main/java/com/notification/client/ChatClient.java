package com.notification.client;


import com.notification.dto.ChatMessageDto;
import com.notification.dto.request.AddParticipantRequest;
import com.notification.dto.response.ChatRoomSummaryResponse;
import org.springframework.cloud.openfeign.FeignClient;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@FeignClient(name = "chat")
public interface ChatClient {


    @PostMapping("/api/chat/{fundingId}/store")
    void storeMessages(@PathVariable int fundingId, @RequestBody List<ChatMessageDto> messages);

    // 채팅방 참여자 추가
    @PostMapping("/api/chatroom/{fundingId}/participants")
    ResponseEntity<?> addParticipant(@PathVariable int fundingId,
                                            @RequestBody AddParticipantRequest request);

    // 참여하고 있는 채팅방 리스트 조회
    @GetMapping("/api/chatroom/user/")
    List<ChatRoomSummaryResponse> getChatRoomsByUserId(@RequestHeader("X-User-Id") int userId );
}
