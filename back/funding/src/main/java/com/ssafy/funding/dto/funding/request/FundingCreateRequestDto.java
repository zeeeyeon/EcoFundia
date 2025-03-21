package com.ssafy.funding.dto.funding.request;

import com.ssafy.funding.entity.Funding;
import com.ssafy.funding.entity.enums.Category;
import lombok.Builder;

import java.time.LocalDateTime;

@Builder
public record FundingCreateRequestDto(
        String title,
        String description,
        int price,
        int quantity,
        int targetAmount,
        LocalDateTime startDate,
        LocalDateTime endDate,
        Category category
) {

    public Funding toEntity(int sellerId, String storyFile, String imageUrlsJson) {
        return Funding.builder()
                .sellerId(sellerId)
                .title(title)
                .description(description)
                .storyFileUrl(storyFile)
                .imageUrls(imageUrlsJson)
                .price(price)
                .quantity(quantity)
                .targetAmount(targetAmount)
                .startDate(startDate)
                .endDate(endDate)
                .category(category)
                .build();
    }
}
