package com.ssafy.funding.dto.review.response;

import java.util.List;

public record ReviewListResponseDto(
        float totalRating,
        List<SingleReviewResponseDto> reviews
) {
}
