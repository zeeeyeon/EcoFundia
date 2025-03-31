package com.ssafy.funding.dto.seller.response;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Builder
@Data
@AllArgsConstructor
@NoArgsConstructor
public class GetSellerBrandStatisticsResponseDto {
    private int generation;
    private double ratio;
}
