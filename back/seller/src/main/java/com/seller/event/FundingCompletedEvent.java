package com.seller.event;

import lombok.*;

import java.time.LocalDateTime;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class FundingCompletedEvent {
    private int fundingId;
    private int sellerId;
    private LocalDateTime settlementTime;
}
