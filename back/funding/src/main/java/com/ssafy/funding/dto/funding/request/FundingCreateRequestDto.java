package com.ssafy.funding.dto.funding.request;

import com.ssafy.funding.entity.Funding;
import com.ssafy.funding.entity.enums.Category;
import lombok.Builder;

import java.io.Serializable;
import java.time.LocalDateTime;

@Builder
public record FundingCreateRequestDto(
        String title,
        String description,
        String storyFileUrl,
        String imageUrls,
        int price,
        int quantity,
        int targetAmount,
        LocalDateTime startDate,
        LocalDateTime endDate,
        Category category
) implements Serializable {
}
