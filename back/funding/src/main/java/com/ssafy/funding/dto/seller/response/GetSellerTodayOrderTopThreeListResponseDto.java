package com.ssafy.funding.dto.seller.response;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Builder
@Data
@NoArgsConstructor
@AllArgsConstructor
public class GetSellerTodayOrderTopThreeListResponseDto {
    private int fundingId;
    private String imageUrl;
    private String title;
    private String description;
    private int currentAmount;
    private int todayAmount;
}
