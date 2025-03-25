package com.ssafy.user.controller;

import com.ssafy.user.common.response.Response;
import com.ssafy.user.dto.request.*;
import com.ssafy.user.dto.response.*;
import com.ssafy.user.service.UserService;
import jakarta.ws.rs.Path;
import lombok.RequiredArgsConstructor;
import org.apache.ibatis.annotations.Delete;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

import static com.ssafy.user.common.response.ResponseCode.*;

@RestController
@RequestMapping("/api/user")
@RequiredArgsConstructor
public class UserController {
    private final UserService userService;

    @PostMapping("/login")
    public ResponseEntity<?> login(@RequestBody LoginRequestDto requestDto) {
        LoginResponseDto dto = userService.verifyUser(requestDto);
        return new ResponseEntity<>(Response.create(SUCCESS, dto), SUCCESS.getHttpStatus());
    }

    @PostMapping("/signup")
    public ResponseEntity<?> signup(@RequestBody SignupRequestDto requestDto) {
        SignupResponseDto dto = userService.registerUser(requestDto);
        return new ResponseEntity<>(Response.create(CREATED, dto), CREATED.getHttpStatus());
    }

    @PostMapping("/reissue")
    public ResponseEntity<?> reissue(@RequestBody ReissueRequestDto requestDto) {
        ReissueResponseDto dto = userService.reissueAccessToken(requestDto);
        return new ResponseEntity<>(Response.create(SUCCESS, dto), SUCCESS.getHttpStatus());
    }

    @GetMapping("/me")
    public ResponseEntity<?> getMyInfo(){
        GetMyInfoResponseDto dto = userService.getMyInfo();
        return new ResponseEntity<>(Response.create(SUCCESS, dto), SUCCESS.getHttpStatus());
    }

    @PutMapping("/me")
    public ResponseEntity<?> updateMyInfo(@RequestBody UpdateMyInfoRequestDto requestDto){
        userService.updateMyInfo(requestDto);
        return new ResponseEntity<>(Response.create(SUCCESS, null), SUCCESS.getHttpStatus());
    }

    // 다른서비스 호출

    @GetMapping("/funding")
    public ResponseEntity<?> getMyFunding(@RequestHeader("X-User-Id") String userId){
        List<FundingResponseDto> dto = userService.getMyFundingDetails(userId);
        return new ResponseEntity<>(Response.create(SUCCESS, dto), SUCCESS.getHttpStatus());
    }

    @GetMapping("/funding/total")
    public ResponseEntity<?> getMyTotalFunding(@RequestHeader("X-User-Id") String userId){
        GetMyTotalFundingResponseDto dto = userService.getMyFundingTotal(userId);
        return new ResponseEntity<>(Response.create(SUCCESS, dto), SUCCESS.getHttpStatus());
    }

    @GetMapping("/review")
    public ResponseEntity<?> getMyReviews(@RequestHeader("X-User-Id") String userId){
        List<ReviewResponseDto> dto = userService.getMyReviews(userId);
        return new ResponseEntity<>(Response.create(SUCCESS, dto), SUCCESS.getHttpStatus());
    }

    @PostMapping("/review")
    public ResponseEntity<?> postMyReview(@RequestHeader("X-User-Id") String userId, @RequestBody PostReviewRequestDto requestDto){
        userService.postMyReview(userId,requestDto);
        return new ResponseEntity<>(Response.create(SUCCESS, null), SUCCESS.getHttpStatus());
    }

    @PatchMapping("/review/{reviewId}")
    public ResponseEntity<?> updateMyReview(@RequestHeader("X-User-Id") String userId, @PathVariable("reviewId") int reviewId, @RequestBody UpdateMyReviewRequestDto requestDto){
        userService.updateMyReview(userId,reviewId,requestDto);
        return new ResponseEntity<>(Response.create(SUCCESS, null), SUCCESS.getHttpStatus());
    }

    @DeleteMapping("/review/{reviewId}")
    public ResponseEntity<?> deleteMyReview(@RequestHeader("X-User-Id") String userId, @PathVariable("reviewId") int reviewId){
        userService.deleteMyReview(userId,reviewId);
        return new ResponseEntity<>(Response.create(SUCCESS, null), SUCCESS.getHttpStatus());
    }

    @PostMapping("/order/funding")
    public ResponseEntity<?> createPayment(@RequestHeader("X-User-Id") String userId, @RequestBody CreatePaymentRequestDto requestDto){
        userService.createPayment(userId,requestDto);
        return new ResponseEntity<>(Response.create(SUCCESS, null), SUCCESS.getHttpStatus());
    }

    @GetMapping("/health")
    public ResponseEntity<?> healthCheck(){
        System.out.println("연결됨!");
        return new ResponseEntity<>(Response.create(SUCCESS, null), SUCCESS.getHttpStatus());
    }


}
