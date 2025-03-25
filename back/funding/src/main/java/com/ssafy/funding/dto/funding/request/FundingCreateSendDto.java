package com.ssafy.funding.dto.funding.request;

import com.ssafy.funding.entity.Funding;
import com.ssafy.funding.entity.enums.Category;

import java.time.LocalDateTime;

public record FundingCreateSendDto(
        String title,
        String description,
        int price,
        int quantity,
        int targetAmount,
        LocalDateTime startDate,
        LocalDateTime endDate,
        String category,
        String storyFileUrl,
        String imageUrlsJson
) {
    public Funding toEntity(int sellerId) {
        return Funding.builder()
                .sellerId(sellerId)
                .title(title)
                .description(description)
                .storyFileUrl(storyFileUrl)
                .imageUrls(imageUrlsJson)
                .price(price)
                .quantity(quantity)
                .targetAmount(targetAmount)
                .startDate(startDate)
                .endDate(endDate)
                .category(Category.valueOf(category))
                .build();
    }
}
