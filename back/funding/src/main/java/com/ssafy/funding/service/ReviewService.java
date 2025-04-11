package com.ssafy.funding.service;

import com.ssafy.funding.dto.review.request.ReviewCreateRequestDto;
import com.ssafy.funding.dto.review.request.ReviewUpdateRequestDto;
import com.ssafy.funding.dto.review.response.ReviewDto;
import com.ssafy.funding.dto.review.response.SingleReviewResponseDto;
import com.ssafy.funding.dto.review.response.ReviewListResponseDto;

import java.util.List;

public interface ReviewService {
    SingleReviewResponseDto getReview(int reviewId);
    ReviewListResponseDto getReviewsByFundingId(int fundingId);
    ReviewListResponseDto getReviewsBySellerId(int sellerId);
    List<ReviewDto> getReviewsByUserId(int userId);
    void createReview(int userId, ReviewCreateRequestDto dto);
    void updateReview(int userId, int reviewId, ReviewUpdateRequestDto dto);
    void deleteReview(int userId, int reviewId);
}
