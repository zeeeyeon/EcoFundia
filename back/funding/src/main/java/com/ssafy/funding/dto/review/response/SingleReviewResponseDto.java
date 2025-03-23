package com.ssafy.funding.dto.review.response;

import com.ssafy.funding.entity.Review;
import lombok.Builder;

import java.time.LocalDateTime;

@Builder
public record SingleReviewResponseDto(
        int rating,
        String content,
        String nickname,
        LocalDateTime createdAt
) {
    public static SingleReviewResponseDto fromEntity(Review review) {
        return SingleReviewResponseDto.builder()
                .rating(review.getRating())
                .content(review.getContent())
                .nickname(review.getNickname())
                .createdAt(review.getCreatedAt())
                .build();
    }
}