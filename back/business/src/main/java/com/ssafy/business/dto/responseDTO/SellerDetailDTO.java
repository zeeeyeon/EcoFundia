package com.ssafy.business.dto.responseDTO;

import com.ssafy.business.dto.SellerFundingDTO;
import lombok.Data;

import java.util.List;

@Data
public class SellerDetailDTO {

    private float totalRating; // rating
    private int ratingCount; // 만족도에 사용된 rating 개수

    private int totalAmount;  // 누적 액수
    private int wishlistCount; // 찜 개수

    List<SellerFundingDTO> onGoingFunding;
    List<SellerFundingDTO> finishFunding;
}
