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
    public ResponseEntity<?> getMyFunding(@RequestHeader("X-User-Id") int userId);

    @GetMapping("/api/user/funding/total")
    public ResponseEntity<?> getMyTotalFunding(@RequestHeader("X-User-Id") int userId);

    @GetMapping("/api/user/review")
    public ResponseEntity<?> getMyReviews(@RequestHeader("X-User-Id") int userId);

    @PostMapping("/api/user/review")
    public ResponseEntity<?> postMyReview(@RequestHeader("X-User-Id") int userId, @RequestBody PostReviewRequestDto requestDto);

    @PatchMapping("/api/user/review/{reviewId}")
    public ResponseEntity<?> updateMyReview(@RequestHeader("X-User-Id") int userId, @PathVariable("reviewId") int reviewId, @RequestBody UpdateMyReviewRequestDto requestDto);

    @DeleteMapping("/api/user/review/{reviewId}")
    public ResponseEntity<?> deleteMyReview(@RequestHeader("X-User-Id") int userId, @PathVariable("reviewId") int reviewId);

    @PostMapping("/api/user/order/funding")
    public ResponseEntity<?> createPayment(@RequestHeader("X-User-Id") int userId, @RequestBody CreatePaymentRequestDto requestDto);


}
