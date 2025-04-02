package com.chat.consumer;

import com.chat.dto.ChatMessageDto;
import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.apache.kafka.clients.consumer.ConsumerRecord;
import org.springframework.kafka.annotation.KafkaListener;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.stereotype.Component;

@Slf4j
@Component
@RequiredArgsConstructor
public class ChatKafkaConsumer {

    private final ObjectMapper objectMapper;
    private final SimpMessagingTemplate template;

    @KafkaListener(topicPattern = "chat-room.*" , groupId = "chat-group")
    public void consume(ConsumerRecord<String, String> record) throws JsonProcessingException {

        String topic = record.topic();
        log.info(topic);
        String fundingId = topic.split("\\.")[1];

        log.info("Consumer value: {}", record.value());

        ChatMessageDto dto = objectMapper.readValue(record.value(), ChatMessageDto.class);

        log.info("Parse Message: {}", dto);

        // WebSocket 브로드캐스트
        template.convertAndSend("/sub/chat/" + fundingId, dto);
    }

}
