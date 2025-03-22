package com.ssafy.user.client;

import com.ssafy.user.dto.request.PostReviewRequestDto;
import com.ssafy.user.dto.request.UpdateMyReviewRequestDto;
import com.ssafy.user.dto.response.FundingResponseDto;
import com.ssafy.user.dto.response.GetMyTotalFundingResponseDto;
import com.ssafy.user.dto.response.ReviewResponseDto;
import org.springframework.cloud.openfeign.FeignClient;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@FeignClient(name = "funding")
public interface FundingClient {
    @GetMapping("/api/funding/my")
    List<FundingResponseDto> getMyFundings(@RequestHeader("X-User-Id") String userId);

    @GetMapping("/api/funding/my/total")
    GetMyTotalFundingResponseDto getMyTotalFunding(@RequestHeader("X-User-Id") String userId);

    @GetMapping("/api/review/my")
    List<ReviewResponseDto> getMyReviews(@RequestHeader("X-User-Id") String userId);

    @PostMapping("/api/review/my")
    void postMyReview(@RequestHeader("X-User-Id") String userId, PostReviewRequestDto requestDto);

    @PutMapping("/api/review/{reviewId}")
    void updateMyReview(@RequestHeader("X-User-Id") String userId, @PathVariable("reviewId") int reviewId, UpdateMyReviewRequestDto requestDto);

    @DeleteMapping("/api/review/{reviewId}")
    void deleteMyReview(@RequestHeader("X-User-Id") String userId, @PathVariable("reviewId") int reviewId);

}
