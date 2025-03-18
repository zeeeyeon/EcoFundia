package com.ssafy.funding.dto.request;

import com.ssafy.funding.entity.Funding;
import com.ssafy.funding.entity.enums.Category;
import lombok.Builder;

import java.time.LocalDateTime;

public record FundingCreateRequestDto(
        int sellerId,
        String title,
        String description,
        String storyFileUrl,
        int price,
        int quantity,
        int targetAmount,
        LocalDateTime startDate,
        LocalDateTime endDate,
        Category category
) {
    @Builder
    public FundingCreateRequestDto {}

    public Funding toEntity(int sellerId) {
        return Funding.builder()
                .sellerId(sellerId)
                .title(title)
                .description(description)
                .storyFileUrl(storyFileUrl)
                .price(price)
                .quantity(quantity)
                .targetAmount(targetAmount)
                .startDate(startDate)
                .category(category)
                .build();
    }


}
