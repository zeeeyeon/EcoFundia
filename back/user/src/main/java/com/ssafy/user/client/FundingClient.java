package com.ssafy.user.client;

import com.ssafy.user.dto.request.PostReviewWithNicknameRequestDto;
import com.ssafy.user.dto.request.UpdateMyReviewRequestDto;
import com.ssafy.user.dto.response.ReviewResponseDto;
import com.ssafy.user.dto.response.WishListResponseDto;
import org.springframework.cloud.openfeign.FeignClient;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@FeignClient(name = "funding")
public interface FundingClient {
    @GetMapping("/api/review/user")
    List<ReviewResponseDto> getMyReviews(@RequestHeader("X-User-Id") int userId);

    @PostMapping("/api/review")
    void postMyReview(@RequestHeader("X-User-Id") int userId, PostReviewWithNicknameRequestDto requestDto);

    @PutMapping("/api/review/{reviewId}")
    void updateMyReview(@RequestHeader("X-User-Id") int userId, @PathVariable("reviewId") int reviewId, UpdateMyReviewRequestDto requestDto);

    @DeleteMapping("/api/review/{reviewId}")
    void deleteMyReview(@RequestHeader("X-User-Id") int userId, @PathVariable("reviewId") int reviewId);



    @PostMapping("/api/wishList/{fundingId}")
    void createWish(@RequestHeader("X-User-Id") int userId, @PathVariable("fundingId") int fundingId);

    @DeleteMapping("/api/wishList/{fundingId}")
    void deleteWish(@RequestHeader("X-User-Id") int userId, @PathVariable("fundingId") int fundingId);

    @GetMapping("/api/wishList/ongoing")
    List<WishListResponseDto> getMyWishList(@RequestHeader("X-User-Id") int userId);

    @GetMapping("/api/wishList/done")
    List<WishListResponseDto> getDoneMyWishList(@RequestHeader("X-User-Id") int userId);

    @GetMapping("/api/wishList/funding-ids")
    List<Integer> getWishListFundingIds(@RequestHeader("X-User-Id") int userId);
}
