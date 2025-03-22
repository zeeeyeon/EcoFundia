package com.ssafy.funding.dto.review.response;

import java.util.List;

public record ReviewsResponseDto(
        float totalRating,
        List<ReviewResponseDto> reviews
) {
}
