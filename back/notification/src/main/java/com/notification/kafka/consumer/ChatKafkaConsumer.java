package com.notification.kafka.consumer;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.notification.buffer.ChatMessageBuffer;
import com.notification.client.ChatClient;
import com.notification.dto.ChatMessageDto;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.apache.kafka.clients.consumer.ConsumerRecord;
import org.springframework.kafka.annotation.KafkaListener;
import org.springframework.kafka.support.Acknowledgment;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.stereotype.Component;

import java.util.List;

@Slf4j
@Component
@RequiredArgsConstructor
public class ChatKafkaConsumer {

    private final ObjectMapper objectMapper;
    private final SimpMessagingTemplate template;
    private final ChatMessageBuffer buffer;
    private final ChatClient chatClient;

    @KafkaListener(topicPattern = "chat-room.*", groupId = "chat-group")
    public void consume(ConsumerRecord<String, String> record, Acknowledgment ack) throws JsonProcessingException {
        try {
            String topic = record.topic();

            String fundingId = topic.split("\\.")[1];

            int intFundingId = Integer.parseInt(fundingId);
            ChatMessageDto dto = objectMapper.readValue(record.value(), ChatMessageDto.class);

            // 메시지 버퍼에 추가
            buffer.addMessage(intFundingId, dto);

            //WebSocket 브로드 캐스트
            template.convertAndSend("/sub/chat/" + fundingId, dto);

            // 50개 도달하면 chat-service로 저장
            if (buffer.isReadyToFlush(intFundingId)) {
                List<ChatMessageDto> messagesToStore = buffer.getAndClearBuffer(intFundingId);
                chatClient.storeMessages(intFundingId, messagesToStore); // 저장 요청
            }
            ack.acknowledge(); // 저장까지 성공한 후에 커밋

        } catch (Exception e) {
            log.error("❌ Kafka 메시지 처리 중 오류: {}", e.getMessage(), e);

        }
    }
}
