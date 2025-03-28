package com.ssafy.funding.dto.funding.request;

import com.ssafy.funding.entity.Funding;
import com.ssafy.funding.entity.enums.Category;

import java.time.LocalDateTime;
import java.time.ZoneId;

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
                .startDate(LocalDateTime.now(ZoneId.of("Asia/Seoul")))
                .endDate(endDate.withHour(23).withMinute(59).withSecond(59))
                .category(Category.valueOf(category))
                .build();
    }
}
