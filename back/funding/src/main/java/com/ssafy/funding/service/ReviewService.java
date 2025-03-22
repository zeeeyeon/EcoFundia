package com.ssafy.funding.service;

import com.ssafy.funding.dto.review.request.ReviewCreateRequestDto;
import com.ssafy.funding.dto.review.request.ReviewUpdateRequestDto;
import com.ssafy.funding.dto.review.response.ReviewResponseDto;
import com.ssafy.funding.dto.review.response.ReviewsResponseDto;

import java.util.List;

public interface ReviewService {
    ReviewResponseDto getReview(int reviewId);
    ReviewsResponseDto getReviewsByFundingId(int fundingId);
    void createReview(int userId, ReviewCreateRequestDto dto);
    void updateReview(int reviewId, ReviewUpdateRequestDto dto);
    void deleteReview(int reviewId);
}
