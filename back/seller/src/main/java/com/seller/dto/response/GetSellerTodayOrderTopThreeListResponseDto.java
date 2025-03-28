package com.seller.dto.response;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@AllArgsConstructor
@NoArgsConstructor
public class GetSellerTodayOrderTopThreeListResponseDto {
    private int fundingId;
    private String imageUrl;
    private String title;
    private String description;
    private int currentAmount;
    private int todayAmount;
}
