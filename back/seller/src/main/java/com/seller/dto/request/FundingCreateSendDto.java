package com.seller.dto.request;

import java.io.Serializable;
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
) implements Serializable {
}
