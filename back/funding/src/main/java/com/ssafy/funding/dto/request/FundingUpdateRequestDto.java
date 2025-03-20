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
        String imageUrls,
        int price,
        int quantity,
        int targetAmount,
        LocalDateTime startDate,
        LocalDateTime endDate,
        Category category,
        Status status,
        LocalDateTime updateAt
) {}
