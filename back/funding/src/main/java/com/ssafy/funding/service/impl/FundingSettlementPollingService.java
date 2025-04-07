package com.ssafy.funding.service.impl;

import com.ssafy.funding.entity.Funding;
import com.ssafy.funding.event.FundingCompletedEvent;
import com.ssafy.funding.service.FundingEventProducer;
import com.ssafy.funding.service.ProductService;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Service;
import java.time.LocalDateTime;
import java.util.List;

/**
 * Scheduled Job - 정산 예약 이벤트 발행
 * - 매일 자정 00:00:05에 SUCCESS 상태이며 아직 settlementCompleted가 false인 펀딩을 조회하여,
 *   펀딩 종료시간에 정산 지연 시간(예: 2시간)을 더한 후 FundingCompletedEvent를 Kafka에 전송함.
 * - 이벤트 전송 플래그 업데이트는 정산 완료 후 Seller 서비스가 Funding 서비스의 REST API 호출로 처리
 */
@Service
@RequiredArgsConstructor
public class FundingSettlementPollingService {

//    // 정산 지연 시간
//    private static final int SETTLEMENT_DELAY_HOURS = 10;

    private final ProductService fundingService;

    private final FundingEventProducer fundingEventProducer;

    // 매일 자정 00:00:05에 실행 (cron 표현식: "초 분 시 일 월 요일")
    @Scheduled(cron = "0 30 11 * * ?")
    public void triggerSettlementEvents() {
        // SUCCESS 상태이며 아직 settlementCompleted가 false인 Funding 목록 조회
        List<Funding> fundingList = fundingService.getSuccessFundingsNotSent();
        for (Funding funding : fundingList) {
            LocalDateTime settlementTime = funding.getEndDate();
            FundingCompletedEvent event = new FundingCompletedEvent(funding.getFundingId(),funding.getSellerId(), settlementTime);
            // Kafka에 FundingCompletedEvent 전송
            fundingEventProducer.sendFundingCompletedEvent(event);
            // settlementCompleted 플래그 업데이트는 정산 완료 후 Seller 서비스에서 자동으로 Funding 서비스의 REST API를 호출하여 처리함
        }
    }
}
