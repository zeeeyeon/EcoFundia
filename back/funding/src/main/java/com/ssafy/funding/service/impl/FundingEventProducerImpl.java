package com.ssafy.funding.service.impl;

import com.ssafy.funding.event.FundingCompletedEvent;
import com.ssafy.funding.service.FundingEventProducer;
import lombok.RequiredArgsConstructor;
import org.springframework.kafka.core.KafkaTemplate;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class FundingEventProducerImpl implements FundingEventProducer {

    private static final String TOPIC = "funding-completed";

    private final KafkaTemplate<String, FundingCompletedEvent> kafkaTemplate;

    @Override
    public void sendFundingCompletedEvent(FundingCompletedEvent event) {
        kafkaTemplate.send(TOPIC, event);
        System.out.println("Sent funding completed event for fundingId: " + event.getFundingId());

    }
}
