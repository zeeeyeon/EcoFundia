package com.ssafy.funding.controller;

import com.ssafy.funding.common.response.Response;
import com.ssafy.funding.common.response.ResponseCode;
import com.ssafy.funding.dto.review.request.ReviewCreateRequestDto;
import com.ssafy.funding.dto.review.request.ReviewUpdateRequestDto;
import com.ssafy.funding.dto.review.response.ReviewDto;
import com.ssafy.funding.dto.review.response.SingleReviewResponseDto;
import com.ssafy.funding.dto.review.response.ReviewListResponseDto;
import com.ssafy.funding.service.ReviewService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

import static com.ssafy.funding.common.response.ResponseCode.*;

@RestController
@RequestMapping("/api/review")
@RequiredArgsConstructor
public class ReviewController {

    private final ReviewService reviewService;

    @GetMapping("/{reviewId}")
    public ResponseEntity<?> getReview(@PathVariable int reviewId) {
        SingleReviewResponseDto review = reviewService.getReview(reviewId);
        return new ResponseEntity<>(Response.create(GET_REVIEW, review), GET_REVIEW.getHttpStatus());
    }

    @GetMapping("/user")
    public List<ReviewDto> getReviewsByUserId(@RequestHeader("X-User-Id") String userId) {
        int user = Integer.parseInt(userId);
        return reviewService.getReviewsByUserId(user);
    }

    @GetMapping("/funding/{fundingId}")
    public ResponseEntity<?> getReviewsByFundingId(@PathVariable int fundingId) {
        ReviewListResponseDto reviews = reviewService.getReviewsByFundingId(fundingId);
        return new ResponseEntity<>(Response.create(GET_REVIEW_LIST, reviews), GET_REVIEW_LIST.getHttpStatus());
    }

    @GetMapping("/seller/{sellerId}")
    public ResponseEntity<?> getReviewsBySeller(@PathVariable int sellerId) {
        ReviewListResponseDto result = reviewService.getReviewsBySellerId(sellerId);
        return new ResponseEntity<>(Response.create(GET_REVIEW_LIST, result), GET_REVIEW_LIST.getHttpStatus());
    }

    // user 에서 요청 받을 때 nickname 도 함께 받는 것 생각해보기
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