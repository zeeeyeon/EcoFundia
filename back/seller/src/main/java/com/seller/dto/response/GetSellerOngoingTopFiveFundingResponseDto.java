package com.seller.dto.response;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Builder
@Data
@AllArgsConstructor
@NoArgsConstructor
public class GetSellerOngoingTopFiveFundingResponseDto {
    private String title;
    private int price;
    private int progressPercentage;
}
