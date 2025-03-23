package com.ssafy.user.client;

import com.ssafy.user.dto.request.*;
import org.springframework.cloud.openfeign.FeignClient;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@FeignClient(name="user")
public interface UserClient {
    @PostMapping("/login")
    public ResponseEntity<?> login(@RequestBody LoginRequestDto requestDto);

    @PostMapping("/signup")
    public ResponseEntity<?> signup(@RequestBody SignupRequestDto requestDto);

    @PostMapping("/reissue")
    public ResponseEntity<?> reissue(@RequestBody ReissueRequestDto requestDto);

    @GetMapping("/me")
    public ResponseEntity<?> getMyInfo();

    @PutMapping("/me")
    public ResponseEntity<?> updateMyInfo(@RequestBody UpdateMyInfoRequestDto requestDto);

    @GetMapping("/funding")
    public ResponseEntity<?> getMyFunding(@RequestHeader("X-User-Id") String userId);

    @GetMapping("/funding/total")
    public ResponseEntity<?> getMyTotalFunding(@RequestHeader("X-User-Id") String userId);

    @GetMapping("/review")
    public ResponseEntity<?> getMyReviews(@RequestHeader("X-User-Id") String userId);

    @PostMapping("/review")
    public ResponseEntity<?> postMyReview(@RequestHeader("X-User-Id") String userId, @RequestBody PostReviewRequestDto requestDto);

    @PutMapping("/review/{reviewId}")
    public ResponseEntity<?> updateMyReview(@RequestHeader("X-User-Id") String userId, @PathVariable("reviewId") int reviewId, @RequestBody UpdateMyReviewRequestDto requestDto);

    @DeleteMapping("/review/{reviewId}")
    public ResponseEntity<?> deleteMyReview(@RequestHeader("X-User-Id") String userId, @PathVariable("reviewId") int reviewId);

    @PostMapping("/order/funding")
    public ResponseEntity<?> createPayment(@RequestHeader("X-User-Id") String userId, @RequestBody CreatePaymentRequestDto requestDto);
}
