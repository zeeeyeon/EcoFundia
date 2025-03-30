package com.seller.service.impl;

import com.seller.event.FundingCompletedEvent;
import com.seller.service.SellerService;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.kafka.annotation.KafkaListener;
import org.springframework.scheduling.TaskScheduler;
import org.springframework.stereotype.Service;
import java.time.ZoneId;
import java.util.Date;

/**
 * Seller Kafka 이벤트 소비자
 * - Funding 서비스에서 발행한 FundingCompletedEvent를 수신하여,
 *   예약된 정산 시각에 SellerSettlementService의 processSettlement 메서드를 실행함
 */
@Service
@Slf4j
public class SellerSettlementConsumer {

    @Autowired
    private TaskScheduler taskScheduler;

    @Autowired
    private SellerService sellerSettlementService;

    // 'funding-completed' 토픽의 메시지를 수신 (groupId: seller-settlement-group)
    @KafkaListener(topics = "funding-completed", groupId = "seller-settlement-group")
    public void handleFundingCompletedEvent(FundingCompletedEvent event) {
        log.info("Seller service received funding completed event for fundingId: {}", event.getFundingId());
        // 예약된 정산 시각에 작업 실행 예약
        Date executionTime = Date.from(event.getSettlementTime().atZone(ZoneId.systemDefault()).toInstant());
        taskScheduler.schedule(() -> sellerSettlementService.processSettlement(event.getFundingId()), executionTime);
    }
}
