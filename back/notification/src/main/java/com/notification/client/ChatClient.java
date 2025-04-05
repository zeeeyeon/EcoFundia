package com.notification.client;


import com.notification.dto.ChatMessageDto;
import org.springframework.cloud.openfeign.FeignClient;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;

import java.util.List;

@FeignClient(name = "chat")
public interface ChatClient {


    @PostMapping("/api/chat/{fundingId}/store")
    void storeMessages(@PathVariable int fundingId, @RequestBody List<ChatMessageDto> messages);
}
