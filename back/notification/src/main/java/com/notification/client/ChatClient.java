package com.notification.client;


import com.notification.dto.ChatMessageDto;
import com.notification.dto.request.AddParticipantRequest;
import org.springframework.cloud.openfeign.FeignClient;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;

import java.util.List;

@FeignClient(name = "chat")
public interface ChatClient {


    @PostMapping("/api/chat/{fundingId}/store")
    void storeMessages(@PathVariable int fundingId, @RequestBody List<ChatMessageDto> messages);

    // 채팅방 참여자 추가
    @PostMapping("/{fundingId}/participants")
    ResponseEntity<?> addParticipant(@PathVariable int fundingId,
                                            @RequestBody AddParticipantRequest request);

}
