package com.seller.dto.response;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Builder
@Data
@AllArgsConstructor
@NoArgsConstructor
public class GetSellerEndFundingListResponseDto {
    private int fundingId;
    private String imageUrl;
    private String title;
    private String description;
    private String remainingTime;
    private int progressPercentage;
    private int price;
}
