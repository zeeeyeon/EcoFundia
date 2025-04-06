package com.chat.controller;

import com.chat.common.response.Response;
import com.chat.dto.response.ChatRoomCreateResponse;
import com.chat.dto.response.ChatRoomSummaryResponse;
import com.chat.dto.reuqest.AddParticipantRequest;
import com.chat.dto.reuqest.ChatRoomCreateRequest;
import com.chat.service.ChatRoomService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

import static com.chat.common.response.ResponseCode.*;

@RestController
@RequestMapping("/api/chatroom")
@RequiredArgsConstructor
public class ChatRoomController {

    private final ChatRoomService chatRoomService;


    // 채팅방 생성
    @PostMapping
    public ChatRoomCreateResponse createRoom(@RequestBody ChatRoomCreateRequest request) {

        ChatRoomCreateResponse response = chatRoomService.createRoom(request);
        return response;
    }

    // 채팅방 참여자 추가
    @PostMapping("/{fundingId}/participants")
    public ResponseEntity<?> addParticipant(@PathVariable int fundingId,
                               @RequestBody AddParticipantRequest request) {
        chatRoomService.addParticipantIfNotExists(fundingId, request.userId());
        return new ResponseEntity<>(Response.create(PARTICIPANT_CHATROOM,null),PARTICIPANT_CHATROOM.getHttpStatus());
    }

    // 참여하고 있는 채팅방 리스트 조회
    @GetMapping("/user/{userId}")
    public List<ChatRoomSummaryResponse> getChatRoomsByUserId(@PathVariable int userId) {
        List<ChatRoomSummaryResponse> chatRooms = chatRoomService.findChatRoomByUserId(userId);
        return chatRooms;
    }

    // 채팅방 나가기
    @DeleteMapping("/{fundingId}/participants/{userId}")
    public ResponseEntity<?> leaveChatRoom(
            @PathVariable int fundingId,
            @PathVariable int userId
    ) {
        chatRoomService.removeParticipant(fundingId, userId);
        return new ResponseEntity<>(Response.create(DELETE_CHATROOM,null),DELETE_CHATROOM.getHttpStatus());
    }
}
