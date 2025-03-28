package com.ssafy.funding.dto.seller.response;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;

@Builder
@Data
@NoArgsConstructor
@AllArgsConstructor
public class GetSellerOngoingTopFiveFundingResponseDto {
    private String title;
    private int price;
    private int progressPercentage;
}
