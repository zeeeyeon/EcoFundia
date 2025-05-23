package com.ssafy.funding.dto.funding.response;

import com.ssafy.funding.common.util.JsonConverter;
import com.ssafy.funding.entity.Funding;
import com.ssafy.funding.entity.enums.Category;
import com.ssafy.funding.entity.enums.Status;

import java.time.LocalDateTime;
import java.util.List;

public record FundingResponseDto(
        String title,
        String description,
        String storyFileUrl,
        List<String> imageUrls,
        int price,
        int targetAmount,
        int currentAmount,
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
                JsonConverter.convertJsonToImageUrls(funding.getImageUrls()),
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