package com.ssafy.funding.controller;

import com.ssafy.funding.common.response.Response;
import com.ssafy.funding.dto.review.request.ReviewCreateRequestDto;
import com.ssafy.funding.dto.review.request.ReviewUpdateRequestDto;
import com.ssafy.funding.dto.review.response.ReviewResponseDto;
import com.ssafy.funding.dto.review.response.ReviewsResponseDto;
import com.ssafy.funding.service.ReviewService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import static com.ssafy.funding.common.response.ResponseCode.*;

@RestController
@RequestMapping("/api/review")
@RequiredArgsConstructor
public class ReviewController {

    private final ReviewService reviewService;

    @GetMapping("/{reviewId}")
    public ResponseEntity<?> getReview(@PathVariable int reviewId) {
        ReviewResponseDto review = reviewService.getReview(reviewId);
        return new ResponseEntity<>(Response.create(GET_REVIEW, review), GET_REVIEW.getHttpStatus());
    }

    @GetMapping("/funding/{fundingId}")
    public ResponseEntity<?> getReviewsByFundingId(@PathVariable int fundingId) {
        ReviewsResponseDto reviews = reviewService.getReviewsByFundingId(fundingId);
        return new ResponseEntity<>(Response.create(GET_REVIEW_LIST, reviews), GET_REVIEW_LIST.getHttpStatus());
    }

    @GetMapping("/seller/{sellerId}")
    public ResponseEntity<?> getReviewsBySeller(@PathVariable int sellerId) {
        ReviewsResponseDto result = reviewService.getReviewsBySellerId(sellerId);
        return new ResponseEntity<>(Response.create(GET_REVIEW_LIST, result), GET_REVIEW_LIST.getHttpStatus());
    }

    @PostMapping
    public ResponseEntity<?> createReview(
            @RequestHeader("X-User-Id") int userId,
            @RequestBody ReviewCreateRequestDto dto) {
        reviewService.createReview(userId, dto);
        return new ResponseEntity<>(Response.create(CREATE_REVIEW, null), CREATE_REVIEW.getHttpStatus());
    }

    @PatchMapping("/{reviewId}")
    public ResponseEntity<?> updateReview(@RequestHeader("X-User-Id") int userId, @PathVariable int reviewId, @RequestBody ReviewUpdateRequestDto dto) {
        reviewService.updateReview(userId, reviewId, dto);
        return new ResponseEntity<>(Response.create(UPDATE_REVIEW, null), UPDATE_REVIEW.getHttpStatus());
    }

    @DeleteMapping("/{reviewId}")
    public ResponseEntity<?> deleteReview(@RequestHeader("X-User-Id") int userId, @PathVariable int reviewId) {
        reviewService.deleteReview(userId, reviewId);
        return new ResponseEntity<>(Response.create(DELETE_REVIEW, null), DELETE_REVIEW.getHttpStatus());
    }
}