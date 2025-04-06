package com.ssafy.user.client;

import org.springframework.cloud.openfeign.FeignClient;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestHeader;

@FeignClient(name = "chat")
public interface ChatClient {

    // 채팅방 나가기
    @DeleteMapping("/api/chatroom/{fundingId}/participants/")
    ResponseEntity<?> leaveChatRoom(
            @RequestHeader("X-User-Id") int userId,
            @PathVariable int fundingId
    );
}
