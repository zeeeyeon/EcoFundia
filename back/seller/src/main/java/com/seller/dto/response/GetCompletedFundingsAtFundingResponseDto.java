package com.seller.dto.response;

import lombok.*;

import java.time.LocalDateTime;


@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class GetCompletedFundingsAtFundingResponseDto {
    private int fundingId;
    private String title;
    private LocalDateTime endDate;
    private int totalAmount;
    private int progressPercentage;
}
