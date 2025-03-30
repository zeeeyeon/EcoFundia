package com.ssafy.funding.event;

import lombok.*;

import java.time.LocalDateTime;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class FundingCompletedEvent {
    private int fundingId;                // 이벤트 대상 펀딩 ID
    private int sellerId;
    private LocalDateTime settlementTime;
}
