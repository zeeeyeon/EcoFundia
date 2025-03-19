package com.ssafy.funding.dto.response;

import com.ssafy.funding.entity.Funding;
import com.ssafy.funding.entity.enums.Category;
import com.ssafy.funding.entity.enums.Status;

import java.time.LocalDateTime;

public record FundingResponseDto(
        String title,
        String description,
        String storyFileUrl,
        int price,
        int quantity,
        int targetAmount,
        LocalDateTime startDate,
        LocalDateTime endDate,
        Category category,
        Status status
) {

    public static FundingResponseDto fromEntity(Funding funding) {
        return new FundingResponseDto(
                funding.getTitle(),
                funding.getDescription(),
                funding.getStoryFileUrl(),
                funding.getPrice(),
                funding.getQuantity(),
                funding.getTargetAmount(),
                funding.getStartDate(),
                funding.getEndDate(),
                funding.getCategory(),
                funding.getStatus()
        );
    }
}