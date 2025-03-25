package com.seller.dto.request;

import java.io.Serializable;
import java.time.LocalDateTime;

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
        String category,
        String status,
        LocalDateTime updateAt
) implements Serializable {}
