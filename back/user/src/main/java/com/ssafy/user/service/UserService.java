package com.ssafy.user.service;

import com.ssafy.user.dto.request.LoginRequestDto;
import com.ssafy.user.dto.request.ReissueRequestDto;
import com.ssafy.user.dto.request.SignupRequestDto;
import com.ssafy.user.dto.response.LoginResponseDto;
import com.ssafy.user.dto.response.ReissueResponseDto;
import com.ssafy.user.dto.response.SignupResponseDto;

public interface UserService {
    LoginResponseDto verifyUser(LoginRequestDto requestDto);
    SignupResponseDto registerUser(SignupRequestDto requestDto);
    ReissueResponseDto reissueAccessToken(ReissueRequestDto requestDto);
}
