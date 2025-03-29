package com.chat.controller;

import com.chat.dto.ChatMessageDto;
import lombok.RequiredArgsConstructor;
import org.springframework.context.annotation.Configuration;
import org.springframework.messaging.handler.annotation.MessageMapping;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequiredArgsConstructor
public class ChatController {

    // 특정 사용자에게 메시지를 보내는데 사용되는 STOMP을 이용한 템플릿
    private final SimpMessagingTemplate template;

    // Message 엔드 포인트로 데이터와 함께 호출하면 "sub/message" 를 수신하는 사용자에게 메세지를 전달합니다.
    @MessageMapping("/message")
    public ChatMessageDto send2(@RequestBody ChatMessageDto chatMessageDto){
        template.convertAndSend("/sub/message", chatMessageDto.getContent());
        return chatMessageDto;
    }
}
