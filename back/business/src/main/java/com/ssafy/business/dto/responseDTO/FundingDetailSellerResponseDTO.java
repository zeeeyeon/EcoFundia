package com.ssafy.business.dto.responseDTO;

import lombok.Builder;
import lombok.Data;

@Data
@Builder
public class FundingDetailSellerResponseDTO {

    private int sellerId;
    private String sellerName; //현재 이거 없음
    private String sellerProfileImageUrl;
}
