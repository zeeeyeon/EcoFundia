package com.ssafy.funding.dto.funding.response;

import com.ssafy.funding.entity.Funding;

import java.time.LocalDateTime;
import java.time.temporal.ChronoUnit;

public record UserWishlistFundingDto(
        int fundingId,
        String title,
        String imageUrl,
        int rate,
        int remainingDays,
        int amountGap,
        String sellerName
) {
    public static UserWishlistFundingDto from(Funding funding, String sellerName) {
        int rate = (int) ((double) funding.getCurrentAmount() / funding.getTargetAmount() * 100);
        int remainingDays = (int) ChronoUnit.DAYS.between(LocalDateTime.now(), funding.getEndDate());
        int amountGap = funding.getCurrentAmount() - funding.getTargetAmount();

        return new UserWishlistFundingDto(
                funding.getFundingId(),
                funding.getTitle(),
                funding.getImageUrlList().get(0),
                rate,
                remainingDays,
                amountGap,
                sellerName
        );
    }
}
