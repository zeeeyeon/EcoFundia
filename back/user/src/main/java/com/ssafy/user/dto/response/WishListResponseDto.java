package com.ssafy.user.dto.response;

import lombok.*;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class WishListResponseDto {
    private int fundingId;
    private String title;
    private String imageUrl;
    private int rate;
    private int remainingDays;
    private int amountGap;
    private String sellerName;

}
