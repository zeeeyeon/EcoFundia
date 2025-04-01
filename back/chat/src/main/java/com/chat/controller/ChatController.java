package com.chat.controller;

import com.chat.dto.ChatMessageDocument;
import com.chat.dto.ChatMessageDto;
import com.chat.repository.ChatMessageRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.messaging.handler.annotation.DestinationVariable;
import org.springframework.messaging.handler.annotation.MessageMapping;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.web.bind.annotation.RestController;

@Slf4j
@RestController
@RequiredArgsConstructor
public class ChatController {

    // 특정 사용자에게 메시지를 보내는데 사용되는 STOMP을 이용한 템플릿
    private final SimpMessagingTemplate template;
    private final ChatMessageRepository chatMessageRepository;

    //  엔드 포인트로 데이터와 함께 호출하면 "sub/chat/{fundingId}" 를 수신하는 사용자에게 메세지를 전달합니다.
    @MessageMapping("/chat/{fundingId}")
    public ChatMessageDto send2(@DestinationVariable(value = "fundingId") int fundingId, ChatMessageDto chatMessageDto){

        log.info("MessageDto: {}", chatMessageDto);

        // MongoDB에 저장
        //ChatMessageDocument document = ChatMessageDocument.toDto(chatMessageDto);
        //chatMessageRepository.save(document);

        template.convertAndSend("/sub/chat/" + fundingId , chatMessageDto);
        return chatMessageDto;
    }

}
