package com.notification.service.impl;

import com.notification.client.ChatClient;
import com.notification.dto.response.ChatRoomSummaryResponse;
import com.notification.service.ChatRoomService;
import lombok.RequiredArgsConstructor;
import org.apache.kafka.clients.admin.AdminClient;
import org.apache.kafka.clients.admin.NewTopic;
import org.springframework.kafka.config.TopicBuilder;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Set;

@Service
@RequiredArgsConstructor
public class ChatRoomServiceImpl implements ChatRoomService {

    private final AdminClient kafkaAdminClient;
    private final ChatClient chatClient;

    public void createChatRoomIfNotExists(int fundingId){

        String topicName = "chat-room." + fundingId;

        try {
            Set<String> existingTopics = kafkaAdminClient.listTopics().names().get();
            if (!existingTopics.contains(topicName)) {
                NewTopic newTopic = TopicBuilder.name(topicName)
                        .partitions(1)
                        .replicas(1)
                        .config("retention.ms","3600000")
                        .build();
                kafkaAdminClient.createTopics(List.of(newTopic)).all().get();
                System.out.println("✅ Kafka 토픽 생성 완료: " + topicName);
            } else {
                System.out.println("✅ Kafka 토픽이미 있음: " + topicName);
            }
        } catch (Exception e) {
            System.err.println("❌ Kafka 토픽 생성 실패: " + e.getMessage());
        }
    }

    @Override
    public List<ChatRoomSummaryResponse> getChatRoomsByUserId(int userId){

        List<ChatRoomSummaryResponse> chatRoomSummaryResponses = chatClient.getChatRoomsByUserId(userId);

        return chatRoomSummaryResponses;
    }
}
