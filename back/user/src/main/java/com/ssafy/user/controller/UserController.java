package com.ssafy.user.controller;

import com.ssafy.user.common.response.Response;
import com.ssafy.user.common.response.ResponseCode;
import com.ssafy.user.dto.request.LoginRequestDto;
import com.ssafy.user.dto.request.ReissueRequestDto;
import com.ssafy.user.dto.request.SignupRequestDto;
import com.ssafy.user.dto.response.GetMyInfoResponseDto;
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
}
