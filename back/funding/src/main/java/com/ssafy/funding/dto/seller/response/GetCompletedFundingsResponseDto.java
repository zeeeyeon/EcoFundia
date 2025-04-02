package com.ssafy.funding.dto.seller.response;

import lombok.*;

import java.time.LocalDateTime;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class GetCompletedFundingsResponseDto {
    private int fundingId;
    private String title;
    private LocalDateTime endDate;
    private int totalAmount;
    private int progressPercentage;
}
