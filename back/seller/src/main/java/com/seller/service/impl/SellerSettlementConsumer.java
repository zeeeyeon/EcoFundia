package com.seller.service.impl;

import com.seller.event.FundingCompletedEvent;
import com.seller.service.SellerService;
import lombok.extern.slf4j.Slf4j;
import org.springframework.kafka.annotation.KafkaListener;
import org.springframework.scheduling.TaskScheduler;
import org.springframework.stereotype.Service;
import java.time.ZoneId;
import java.util.Date;

@Service
@Slf4j
public class SellerSettlementConsumer {

    private final TaskScheduler taskScheduler;
    private final SellerService sellerSettlementService;

    public SellerSettlementConsumer(TaskScheduler taskScheduler, SellerService sellerSettlementService) {
        this.taskScheduler = taskScheduler;
        this.sellerSettlementService = sellerSettlementService;
    }

    @KafkaListener(topics = "funding-completed", groupId = "my-group", containerFactory = "kafkaListenerContainerFactory")
    public void handleFundingCompletedEvent(FundingCompletedEvent event) {
        log.info("Received event: {}", event);
        Date executionTime = Date.from(event.getSettlementTime().atZone(ZoneId.systemDefault()).toInstant());
        taskScheduler.schedule(() -> sellerSettlementService.processSettlement(event.getFundingId(), event.getSellerId()), executionTime);
    }
}
