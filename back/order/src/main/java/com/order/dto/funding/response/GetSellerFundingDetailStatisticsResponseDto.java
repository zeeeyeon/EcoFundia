package com.order.dto.funding.response;

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
