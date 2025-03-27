package com.ssafy.funding.entity;

import com.ssafy.funding.common.util.JsonConverter;
import com.ssafy.funding.dto.funding.response.FundingWishCountResponseDto;
import com.ssafy.funding.dto.funding.response.GetFundingResponseDto;
import com.ssafy.funding.entity.enums.Category;
import com.ssafy.funding.entity.enums.Status;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Getter
@NoArgsConstructor
@AllArgsConstructor
public class FundingWishCount {

    private int fundingId;
    private int sellerId;
    private String title;
    private String description;
    private String storyFileUrl;
    private String imageUrls;
    private int price;
    private int quantity;
    private int targetAmount;
    private int currentAmount;
    private LocalDateTime startDate;
    private LocalDateTime endDate;

    private Status status;
    private Category category;

    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;

    private int wishCount;


    public FundingWishCountResponseDto toDto() {
        return FundingWishCountResponseDto
                .builder()
                .fundingId(fundingId)
                .sellerId(sellerId)
                .title(title)
                .storyFileUrl(storyFileUrl)
                .imageUrls(JsonConverter.convertJsonToImageUrls(imageUrls))
                .description(description)
                .price(price)
                .quantity(quantity)
                .targetAmount(targetAmount)
                .currentAmount(currentAmount)
                .startDate(startDate)
                .endDate(endDate)
                .status(status)
                .category(category)
                .rate( (int) ((double) currentAmount / targetAmount * 100) )
                .wishCount(wishCount)
                .build();
    }
}
