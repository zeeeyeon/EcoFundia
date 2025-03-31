package com.ssafy.funding.dto.seller;

import com.ssafy.funding.entity.enums.Status;
import lombok.Data;

import java.util.ArrayList;
import java.util.List;

@Data
public class SellerDetailResponseDto {

    private float totalRating; // rating
    private int ratingCount; // 만족도에 사용된 rating 개수

    private int totalAmount;  // 누적 액수
    private int wishlistCount; // 찜 개수

    List<SellerFundingDto> onGoingFunding;
    List<SellerFundingDto> finishFunding;

    public static SellerDetailResponseDto from(List<SellerDetailDto> sellerDetailList) {
        int totalRatingSum = 0;
        int totalRatingCount = 0;
        int totalWishlistCount = 0;
        int totalSuccessAmount = 0;

        List<SellerFundingDto> onGoingFunding = new ArrayList<>();
        List<SellerFundingDto> finishFunding = new ArrayList<>();

        for (SellerDetailDto dto : sellerDetailList) {
            totalRatingSum += dto.getTotalRating();
            totalRatingCount += dto.getRatingCount();
            totalWishlistCount += dto.getWishlistCount();

            if (dto.getStatus() == Status.SUCCESS) {
                totalSuccessAmount += dto.getCurrentAmount();
            }

            SellerFundingDto fundingDto = SellerFundingDto.from(dto);

            if (dto.getStatus() == Status.ONGOING) {
                onGoingFunding.add(fundingDto);
            } else {
                finishFunding.add(fundingDto);
            }
        }

        SellerDetailResponseDto response = new SellerDetailResponseDto();
        response.setTotalRating(totalRatingCount == 0 ? 0.0f  : Math.round((totalRatingSum / (float) totalRatingCount) * 10) / 10.0f);
        response.setRatingCount(totalRatingCount);
        response.setWishlistCount(totalWishlistCount);
        response.setTotalAmount(totalSuccessAmount);
        response.setOnGoingFunding(onGoingFunding);
        response.setFinishFunding(finishFunding);

        return response;
    }
}
