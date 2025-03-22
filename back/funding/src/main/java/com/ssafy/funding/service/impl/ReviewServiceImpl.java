package com.ssafy.funding.service.impl;

import com.ssafy.funding.common.exception.CustomException;
import com.ssafy.funding.dto.review.request.ReviewCreateRequestDto;
import com.ssafy.funding.dto.review.request.ReviewUpdateRequestDto;
import com.ssafy.funding.dto.review.response.ReviewResponseDto;
import com.ssafy.funding.dto.review.response.ReviewsResponseDto;
import com.ssafy.funding.entity.Review;
import com.ssafy.funding.entity.enums.Status;
import com.ssafy.funding.mapper.ReviewMapper;
import com.ssafy.funding.service.ProductService;
import com.ssafy.funding.service.ReviewService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

import static com.ssafy.funding.common.response.ResponseCode.*;

@Service
@RequiredArgsConstructor
public class ReviewServiceImpl implements ReviewService {

    private final ReviewMapper reviewMapper;
    private final ProductService productService;
//    private final UserClient userClient;


    @Override
    public ReviewResponseDto getReview(int reviewId) {
        Review review = findByReviewId(reviewId);
        if (review == null) throw new CustomException(REVIEW_NOT_FOUND);
        return ReviewResponseDto.fromEntity(review);
    }


    @Override
    public ReviewsResponseDto getReviewsByFundingId(int fundingId) {
        List<Review> reviews = reviewMapper.findByFundingId(fundingId);
        return aggregateRatingAndReviews(reviews);
    }

    @Override
    public ReviewsResponseDto getReviewsBySellerId(int sellerId) {
        List<Review> reviews = reviewMapper.findBySellerId(sellerId);
        return aggregateRatingAndReviews(reviews);
    }


    @Override
    @Transactional
    public void createReview(int userId, ReviewCreateRequestDto dto) {
        Status status = productService.getFundingStatus(dto.fundingId());
        if (status != Status.SUCCESS) throw new CustomException(REVIEW_NOT_ALLOWED);
        if (reviewMapper.existsByUserIdAndFundingId(userId, dto.fundingId())) throw new CustomException(REVIEW_ALREADY_EXISTS);

//        String nickname = userClient.getNickname(userId);

//        Review review = dto.toEntity(userId, nickname);
//        reviewMapper.createReview(review);
    }

    @Override
    @Transactional
    public void updateReview(int userId, int reviewId, ReviewUpdateRequestDto dto) {
        Review review = findByReviewId(reviewId);
        validateReviewAccess(review, userId);

        review.update(dto.content(), dto.rating());
        reviewMapper.updateReview(review);
    }

    @Override
    @Transactional
    public void deleteReview(int userId, int reviewId) {
        Review review = findByReviewId(reviewId);
        validateReviewAccess(review, userId);

        reviewMapper.deleteReview(reviewId);
    }

    private Review findByReviewId(int reviewId) {
        return reviewMapper.findById(reviewId);
    }

    private ReviewsResponseDto aggregateRatingAndReviews(List<Review> reviews) {
        if (reviews.isEmpty()) {
            return new ReviewsResponseDto(0f, List.of());
        }

        float average = (float) reviews.stream()
                .mapToInt(Review::getRating)
                .average()
                .orElse(0.0);

        List<ReviewResponseDto> responseList = reviews.stream()
                .map(ReviewResponseDto::fromEntity)
                .toList();

        return new ReviewsResponseDto(average, responseList);
    }

    private void validateReviewAccess(Review review, int userId) {
        if (review == null) throw new CustomException(REVIEW_NOT_FOUND);
        if (review.getUserId() != userId) throw new CustomException(FORBIDDEN_REVIEW_ACCESS);
    }
}
