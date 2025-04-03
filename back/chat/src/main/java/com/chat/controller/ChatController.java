package com.chat.controller;

import com.chat.dto.ChatMessageDocument;
import com.chat.dto.ChatMessageDto;
import com.chat.dto.response.ChatPageResponseDto;
import com.chat.producer.ChatKafkaProducer;
import com.chat.repository.ChatMessageRepository;
import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.messaging.handler.annotation.DestinationVariable;
import org.springframework.messaging.handler.annotation.MessageMapping;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.web.bind.annotation.*;

import java.util.List;

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

    // 채팅 색션에 들어갔을 때 채팅방 리스트와 마지막 채팅 내역 조회
    @GetMapping("/chat/list")
    public List<ChatPageResponseDto> getChatPageList(@RequestHeader("X-User-Id") int userId){
        return null;
    }

    // 특정 채팅에 들어갔을때 그 채팅 메시지 내역 조회 20건씩 조회
    // kafka에 해당 토픽에 메시지가 있는지 확인하고
    @GetMapping("/chat/record")
    public List<ChatMessageDto> getChatRecord(@RequestParam(name = "fundingId") int fundingId, @RequestParam( name = "page" ) int page){
        return null;
    }

    //카프카

}
