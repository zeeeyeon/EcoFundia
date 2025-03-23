package com.ssafy.funding.dto.review.request;

import com.ssafy.funding.entity.Review;
import lombok.Builder;

@Builder
public record ReviewCreateRequestDto(
        int fundingId,
        int rating,
        String content
) {
    public Review toEntity(int userId, String nickname) {
        return Review.builder()
                .userId(userId)
                .fundingId(fundingId)
                .rating(rating)
                .content(content)
                .nickname(nickname)
                .build();
    }
}