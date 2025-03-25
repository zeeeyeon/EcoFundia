package com.seller.dto.request;

import java.io.Serializable;
import java.time.LocalDateTime;

@Builder
public record FundingCreateRequestDto (
        String title,
        String description,
        int price,
        int quantity,
        int targetAmount,
        LocalDateTime startDate,
        LocalDateTime endDate,
        String category
) implements Serializable {}