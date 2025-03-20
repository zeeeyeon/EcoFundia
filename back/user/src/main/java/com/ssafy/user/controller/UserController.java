package com.ssafy.user.controller;

import com.ssafy.user.common.response.Response;
import com.ssafy.user.common.response.ResponseCode;
import com.ssafy.user.dto.request.LoginRequestDto;
import com.ssafy.user.dto.request.ReissueRequestDto;
import com.ssafy.user.dto.request.SignupRequestDto;
import com.ssafy.user.dto.response.LoginResponseDto;
import com.ssafy.user.dto.response.ReissueResponseDto;
import com.ssafy.user.dto.response.SignupResponseDto;
import com.ssafy.user.service.UserService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import static com.ssafy.user.common.response.ResponseCode.*;

@RestController
@RequestMapping("/user")
@RequiredArgsConstructor
public class UserController {
    private final UserService userService;

    @PostMapping("/login")
    public ResponseEntity<?> login(@RequestBody LoginRequestDto requestDto) {
        LoginResponseDto loginResponse = userService.verifyUser(requestDto);
        return new ResponseEntity<>(Response.create(SUCCESS, loginResponse), SUCCESS.getHttpStatus());
    }

    @PostMapping("/signup")
    public ResponseEntity<?> signup(@RequestBody SignupRequestDto requestDto) {
        SignupResponseDto signupResponse = userService.registerUser(requestDto);
        return new ResponseEntity<>(Response.create(CREATED, signupResponse), CREATED.getHttpStatus());
    }

    @PostMapping("/reissue")
    public ResponseEntity<?> reissue(@RequestBody ReissueRequestDto requestDto) {
        ReissueResponseDto reissueResponse = userService.reissueAccessToken(requestDto);
        return new ResponseEntity<>(Response.create(SUCCESS, reissueResponse), SUCCESS.getHttpStatus());
    }

    @PostMapping("/logout")
    public ResponseEntity<?> logout(){
        return new ResponseEntity<>(Response.create(LOGOUT_SUCCESS, null), LOGOUT_SUCCESS.getHttpStatus());
    }
}
