package com.notification.controller;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.notification.dto.ChatMessageDto;
import com.notification.kafka.producer.ChatKafkaProducer;
import lombok.RequiredArgsConstructor;
import org.springframework.messaging.handler.annotation.DestinationVariable;
import org.springframework.messaging.handler.annotation.MessageMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequiredArgsConstructor
public class ChatController {

    private final ChatKafkaProducer chatKafkaProducer;
    private final ObjectMapper objectMapper;

    @MessageMapping("/chat/{fundingId}")
    public void handleMessage(@DestinationVariable(value = "fundingId") int fundingId, ChatMessageDto chatMessageDto) throws JsonProcessingException {

        String json = objectMapper.writeValueAsString(chatMessageDto);
        chatKafkaProducer.send(fundingId, json);


    }
}

