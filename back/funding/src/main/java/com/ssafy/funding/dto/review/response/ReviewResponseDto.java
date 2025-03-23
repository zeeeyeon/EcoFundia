package com.ssafy.funding.dto.review.response;

import lombok.Builder;
import lombok.Data;

import java.util.List;

@Data
@Builder
public class ReviewResponseDto {

    private float totalRating;
    private List<ReviewDto> reviews;
}
