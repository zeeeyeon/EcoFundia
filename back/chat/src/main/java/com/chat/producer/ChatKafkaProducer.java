package com.chat.producer;

import lombok.RequiredArgsConstructor;
import org.springframework.kafka.core.KafkaTemplate;
import org.springframework.stereotype.Service;

@RequiredArgsConstructor
@Service
public class ChatKafkaProducer {

    private final KafkaTemplate<String, String> kafkaTemplate;

    public void send(int fundingId, String messageJson) {
        String topic = "chat-room." + fundingId;
        kafkaTemplate.send(topic, messageJson);
    }
}
