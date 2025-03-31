package com.ssafy.funding.dto.seller.response;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Builder
@Data
@NoArgsConstructor
@AllArgsConstructor
public class GetSellerFundingDetailStatisticsResponseDto {
    private int generation;
    private double ratio;
}