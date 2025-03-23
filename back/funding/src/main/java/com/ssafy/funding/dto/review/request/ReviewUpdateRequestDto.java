package com.ssafy.funding.dto.review.request;

import lombok.Builder;

@Builder
public record ReviewUpdateRequestDto(
        String content,
        int rating
) {
}