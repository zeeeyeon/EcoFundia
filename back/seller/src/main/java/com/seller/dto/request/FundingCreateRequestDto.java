package com.seller.dto.request;

import java.io.Serializable;
import java.time.LocalDateTime;

public record FundingCreateRequestDto(
        String title,
        String description,
        int price,
        int quantity,
        int targetAmount,
        LocalDateTime endDate,
        String category

) implements Serializable {

    public FundingCreateSendDto toDto(String storyFileUrl, String imageUrlsJson) {
        return new FundingCreateSendDto(
                this.title,
                this.description,
                this.price,
                this.quantity,
                this.targetAmount,
                this.endDate,
                this.category,
                storyFileUrl,
                imageUrlsJson
        );
    }
}