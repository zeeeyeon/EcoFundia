package com.ssafy.user.service;

import com.ssafy.user.dto.request.LoginRequestDto;
import com.ssafy.user.dto.request.ReissueRequestDto;
import com.ssafy.user.dto.request.SignupRequestDto;
import com.ssafy.user.dto.request.UpdateMyInfoRequestDto;
import com.ssafy.user.dto.response.*;

import java.util.List;

public interface UserService {
    LoginResponseDto verifyUser(LoginRequestDto requestDto);
    SignupResponseDto registerUser(SignupRequestDto requestDto);
    ReissueResponseDto reissueAccessToken(ReissueRequestDto requestDto);
    GetMyInfoResponseDto getMyInfo();

    void updateMyInfo(UpdateMyInfoRequestDto requestDto);

    // 외부서비스 호출
    public List<FundingResponseDto> getMyFundingDetails(int userId);

    GetMyTotalFundingResponseDto getMyFundingTotal(int userId);

}
