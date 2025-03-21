package com.ssafy.business.dto;

import lombok.Builder;
import lombok.Data;

@Data
@Builder
public class FundingDetailSellerDTO {

    private int sellerId;
    private String sellerName; //현재 이거 없음
    private String sellerProfileImageUrl;
}
