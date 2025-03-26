package com.ssafy.user.controller;

import com.ssafy.user.common.response.PageResponse;
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
        return new ResponseEntity<>(Response.create(LOGIN_SUCCESS, dto), LOGIN_SUCCESS.getHttpStatus());
    }

    @PostMapping("/signup")
    public ResponseEntity<?> signup(@RequestBody SignupRequestDto requestDto) {
        SignupResponseDto dto = userService.registerUser(requestDto);
        return new ResponseEntity<>(Response.create(CREATE_USER, dto), CREATE_USER.getHttpStatus());
    }

    @PostMapping("/reissue")
    public ResponseEntity<?> reissue(@RequestBody ReissueRequestDto requestDto) {
        ReissueResponseDto dto = userService.reissueAccessToken(requestDto);
        return new ResponseEntity<>(Response.create(REISSUE_SUCCESS, dto), REISSUE_SUCCESS.getHttpStatus());
    }

    @GetMapping("/me")
    public ResponseEntity<?> getMyInfo(@RequestHeader("X-User-Id") int userId){
        GetMyInfoResponseDto dto = userService.getMyInfo(userId);
        return new ResponseEntity<>(Response.create(GET_MYINFO, dto), GET_MYINFO.getHttpStatus());
    }

    @PutMapping("/me")
    public ResponseEntity<?> updateMyInfo(@RequestHeader("X-User-Id") int userId, @RequestBody UpdateMyInfoRequestDto requestDto){
        userService.updateMyInfo(userId, requestDto);
        return new ResponseEntity<>(Response.create(UPDATE_MYINFO, null), UPDATE_MYINFO.getHttpStatus());
    }

    // 다른서비스 호출

    @GetMapping("/funding")
    public ResponseEntity<?> getMyFunding(
            @RequestHeader("X-User-Id") int userId,
            @RequestParam(name = "page",defaultValue = "0") int page,
            @RequestParam(name = "size",defaultValue = "10") int size) {

        PageResponse<FundingResponseDto> dto = userService.getMyFundingDetails(userId, page, size);
        return new ResponseEntity<>(Response.create(GET_MY_FUNDING_SUCCESS, dto), GET_MY_FUNDING_SUCCESS.getHttpStatus());
    }

    @GetMapping("/funding/total")
    public ResponseEntity<?> getMyTotalFunding(@RequestHeader("X-User-Id") int userId){
        GetMyTotalFundingResponseDto dto = userService.getMyFundingTotal(userId);
        return new ResponseEntity<>(Response.create(GET_MY_TOTAL_FUNDING_SUCCESS, dto), GET_MY_TOTAL_FUNDING_SUCCESS.getHttpStatus());
    }

    @GetMapping("/review")
    public ResponseEntity<?> getMyReviews(
            @RequestHeader("X-User-Id") int userId,
            @RequestParam(name = "page", defaultValue = "0") int page,
            @RequestParam(name = "size", defaultValue = "10") int size) {

        PageResponse<ReviewResponseDto> dto = userService.getMyReviews(userId, page, size);
        return new ResponseEntity<>(Response.create(GET_MY_REVIEW_SUCCESS, dto), GET_MY_REVIEW_SUCCESS.getHttpStatus());
    }

    @PostMapping("/review")
    public ResponseEntity<?> postMyReview(
            @RequestHeader("X-User-Id") int userId,
            @RequestBody PostReviewRequestDto requestDto) {

        userService.postMyReview(userId, requestDto);
        return new ResponseEntity<>(Response.create(CREATE_MY_REVIEW_SUCCESS, null), CREATE_MY_REVIEW_SUCCESS.getHttpStatus());
    }

    @PutMapping("/review/{reviewId}")
    public ResponseEntity<?> updateMyReview(
            @RequestHeader("X-User-Id") int userId,
            @PathVariable int reviewId,
            @RequestBody UpdateMyReviewRequestDto requestDto) {

        userService.updateMyReview(userId, reviewId, requestDto);
        return new ResponseEntity<>(Response.create(UPDATE_MY_REVIEW_SUCCESS, null), UPDATE_MY_REVIEW_SUCCESS.getHttpStatus());
    }

    @DeleteMapping("/review/{reviewId}")
    public ResponseEntity<?> deleteMyReview(
            @RequestHeader("X-User-Id") int userId,
            @PathVariable int reviewId) {

        userService.deleteMyReview(userId, reviewId);
        return new ResponseEntity<>(Response.create(DELETE_MY_REVIEW_SUCCESS, null), DELETE_MY_REVIEW_SUCCESS.getHttpStatus());
    }

    @PostMapping("/order/funding")
    public ResponseEntity<?> createPayment(
            @RequestHeader("X-User-Id") int userId,
            @RequestBody CreatePaymentRequestDto requestDto) {

        OrderResponseDto dto = userService.createPayment(userId, requestDto);
        return new ResponseEntity<>(Response.create(CREATE_PAYMENT_SUCCESS, dto), CREATE_PAYMENT_SUCCESS.getHttpStatus());
    }


    @GetMapping("/health")
    public ResponseEntity<?> healthCheck(){
        System.out.println("연결됨!");
        return new ResponseEntity<>(Response.create(SUCCESS, null), SUCCESS.getHttpStatus());
    }


}
