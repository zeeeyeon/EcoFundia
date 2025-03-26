package com.ssafy.user.service;

import com.ssafy.user.common.response.PageResponse;
import com.ssafy.user.dto.request.*;
import com.ssafy.user.dto.response.*;

import java.util.List;

public interface UserService {
    LoginResponseDto verifyUser(LoginRequestDto requestDto);
    SignupResponseDto registerUser(SignupRequestDto requestDto);
    ReissueResponseDto reissueAccessToken(ReissueRequestDto requestDto);
    GetMyInfoResponseDto getMyInfo();

    void updateMyInfo(UpdateMyInfoRequestDto requestDto);

    // 외부서비스 호출

    PageResponse<FundingResponseDto> getMyFundingDetails(int userId, int page, int size);

    GetMyTotalFundingResponseDto getMyFundingTotal(int userId);

    PageResponse<ReviewResponseDto> getMyReviews(int userId, int page, int size);

    void postMyReview(int userId, PostReviewRequestDto requestDto);

    void updateMyReview(int userId, int reviewId, UpdateMyReviewRequestDto requestDto);

    void deleteMyReview(int userId, int reviewId);

    void createPayment(int userId, CreatePaymentRequestDto requestDto);

}
