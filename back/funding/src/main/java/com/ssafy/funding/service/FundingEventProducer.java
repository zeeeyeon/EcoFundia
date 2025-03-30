package com.ssafy.funding.service;

import com.ssafy.funding.event.FundingCompletedEvent;

/**
 * Funding 이벤트 프로듀서 인터페이스
 * - FundingCompletedEvent를 Kafka로 전송하는 기능 정의
 */
public interface FundingEventProducer {
    void sendFundingCompletedEvent(FundingCompletedEvent event);
}
