package com.ssafy.funding.dto.request;

import com.ssafy.funding.entity.enums.Category;

import java.time.LocalDateTime;

public record FundingCreateRequestDto(
        Integer sellerId,
        String title,
        String description,
        String storyFileUrl,
        Integer price,
        Integer quantity,
        Integer targetAmount,
        LocalDateTime startDate,
        LocalDateTime endDate,
        Category category
) {}
