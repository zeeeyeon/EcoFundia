package com.ssafy.user.client;

import com.ssafy.user.dto.request.*;
import org.springframework.cloud.openfeign.FeignClient;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@FeignClient(name="user")
public interface UserClient {
    @PostMapping("/api/user/login")
    public ResponseEntity<?> login(@RequestBody LoginRequestDto requestDto);

    @PostMapping("/api/user/signup")
    public ResponseEntity<?> signup(@RequestBody SignupRequestDto requestDto);

    @PostMapping("/api/user/reissue")
    public ResponseEntity<?> reissue(@RequestBody ReissueRequestDto requestDto);

    @GetMapping("/api/user/me")
    public ResponseEntity<?> getMyInfo();

    @PutMapping("/api/user/me")
    public ResponseEntity<?> updateMyInfo(@RequestBody UpdateMyInfoRequestDto requestDto);

    @GetMapping("/api/user/health")
    public ResponseEntity<?> healthCheck();

    @GetMapping("/api/user/funding")
    public ResponseEntity<?> getMyFunding(
            @RequestHeader("X-User-Id") int userId,
            @RequestParam(name = "page",defaultValue = "0") int page,
            @RequestParam(name = "size",defaultValue = "10") int size);

    @GetMapping("/api/user/funding/total")
    public ResponseEntity<?> getMyTotalFunding(@RequestHeader("X-User-Id") int userId);

    @GetMapping("/api/user/review")
    public ResponseEntity<?> getMyReviews(
            @RequestHeader("X-User-Id") int userId,
            @RequestParam(name = "page", defaultValue = "0") int page,
            @RequestParam(name = "size", defaultValue = "10") int size);

    @PostMapping("/api/user/review")
    public ResponseEntity<?> postMyReview(@RequestHeader("X-User-Id") int userId, @RequestBody PostReviewRequestDto requestDto);

    @PutMapping("/api/user/review/{reviewId}")
    public ResponseEntity<?> updateMyReview(@RequestHeader("X-User-Id") int userId, @PathVariable("reviewId") int reviewId, @RequestBody UpdateMyReviewRequestDto requestDto);

    @DeleteMapping("/api/user/review/{reviewId}")
    public ResponseEntity<?> deleteMyReview(@RequestHeader("X-User-Id") int userId, @PathVariable("reviewId") int reviewId);

    @PostMapping("/api/user/order/funding")
    public ResponseEntity<?> createPayment(@RequestHeader("X-User-Id") int userId, @RequestBody CreatePaymentRequestDto requestDto);

    @PostMapping("/api/user/wishList/{fundingId}")
    public ResponseEntity<?> createWish(@RequestHeader("X-User-Id") int userId, @PathVariable int fundingId);

    @GetMapping("/api/user/wishList/ongoing")
    public ResponseEntity<?> getMyWishList(@RequestHeader("X-User-Id") int userId, @RequestParam(name = "page",defaultValue = "0") int page, @RequestParam(name = "size",defaultValue = "10") int size);

    @GetMapping("/api/user/wishList/done")
    public ResponseEntity<?> getDoneMyWishList(@RequestHeader("X-User-Id") int userId, @RequestParam(name = "page",defaultValue = "0") int page, @RequestParam(name = "size",defaultValue = "10") int size);

    @DeleteMapping("/api/user/wishList/{fundingId}")
    public ResponseEntity<?> deleteWish(@RequestHeader("X-User-Id") int userId, @PathVariable int fundingId);
}
