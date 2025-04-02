package com.chat.controller;

import com.chat.dto.ChatMessageDocument;
import com.chat.dto.ChatMessageDto;
import com.chat.producer.ChatKafkaProducer;
import com.chat.repository.ChatMessageRepository;
import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
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
    // 카프카 쓸거니까 주석
    // private final SimpMessagingTemplate template;
    //private final ChatMessageRepository chatMessageRepository;

    private final ChatKafkaProducer chatKafkaProducer;
    private final ObjectMapper objectMapper;

    //  엔드 포인트로 데이터와 함께 호출하면 "sub/chat/{fundingId}" 를 수신하는 사용자에게 메세지를 전달합니다.
    @MessageMapping("/chat/{fundingId}")
    public void handleMessage(@DestinationVariable(value = "fundingId") int fundingId, ChatMessageDto chatMessageDto) throws JsonProcessingException {

        log.info("MessageDto: {}", chatMessageDto);

        String json = objectMapper.writeValueAsString(chatMessageDto);
        chatKafkaProducer.send(fundingId, json);

        // MongoDB에 저장
        //ChatMessageDocument document = ChatMessageDocument.toDto(chatMessageDto);
        //chatMessageRepository.save(document);

    }

}
