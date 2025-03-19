package com.ssafy.funding.dto.request;

import com.ssafy.funding.entity.enums.Category;
import com.ssafy.funding.entity.enums.Status;
import lombok.Builder;

import java.time.LocalDateTime;

@Builder
public record FundingUpdateRequestDto(
        String title,
        String description,
        String storyFileUrl,
        int price,
        int quantity,
        int targetAmount,

        LocalDateTime startDate,
        LocalDateTime endDate,

        Category category,
        Status status,

        LocalDateTime updateAt
) {
//    public Funding toEntity(int sellerId) {
//        return Funding.builder()
//                .sellerId(sellerId)
//                .title(title)
//                .description(description)
//                .storyFileUrl(storyFileUrl)
//                .price(price)
//                .quantity(quantity)
//                .targetAmount(targetAmount)
//                .startDate(startDate)
//                .endDate(endDate)
//                .category(category)
//                .status(status)
//                .build();
//    }
}
