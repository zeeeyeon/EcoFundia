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
        LocalDateTime endDate,
        String category,
        String status
) implements Serializable {

    public FundingUpdateSendDto toDto(String storyFileUrl, String imageUrlsJson) {
        return new FundingUpdateSendDto(
                title,
                description,
                price,
                quantity,
                targetAmount,
                endDate,
                category,
                status,
                storyFileUrl,
                imageUrlsJson
        );
    }
}