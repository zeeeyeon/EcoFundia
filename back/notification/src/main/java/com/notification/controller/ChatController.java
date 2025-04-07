package com.notification.controller;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.notification.common.response.Response;
import com.notification.dto.ChatMessageDto;
import com.notification.dto.response.ChatRoomSummaryResponse;
import com.notification.kafka.producer.ChatKafkaProducer;
import com.notification.service.ChatRoomService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.messaging.handler.annotation.DestinationVariable;
import org.springframework.messaging.handler.annotation.MessageMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

import static com.notification.common.response.ResponseCode.*;

@RestController
@RequiredArgsConstructor
public class ChatController {

    private final ChatKafkaProducer chatKafkaProducer;
    private final ObjectMapper objectMapper;
    private final ChatRoomService chatRoomService;

    @MessageMapping("/chat/{fundingId}")
    public void handleMessage(@DestinationVariable(value = "fundingId") int fundingId, ChatMessageDto chatMessageDto) throws JsonProcessingException {

        String json = objectMapper.writeValueAsString(chatMessageDto);
        chatKafkaProducer.send(fundingId, json);

    }

    @GetMapping("/api/notification/chat/user")
    public ResponseEntity<?> getChatRoomByUserId(
            @RequestHeader("X-User-Id") int userId
    ){
        List<ChatRoomSummaryResponse> response = chatRoomService.getChatRoomsByUserId(userId);
        return new ResponseEntity<>(Response.create(GET_CHATROOM_LIST, response), GET_CHATROOM_LIST.getHttpStatus());
    }
}

