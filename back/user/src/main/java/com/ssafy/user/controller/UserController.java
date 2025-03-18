package com.ssafy.user.controller;

import com.ssafy.user.dto.request.LoginRequestDto;
import com.ssafy.user.dto.request.ReissueRequestDto;
import com.ssafy.user.dto.request.SignupRequestDto;
import com.ssafy.user.dto.response.LoginResponseDto;
import com.ssafy.user.dto.response.ReissueResponseDto;
import com.ssafy.user.dto.response.SignupResponseDto;
import com.ssafy.user.service.UserService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/user")
public class UserController {
    @Autowired
    private UserService userService;

    @PostMapping("/login")
    public ResponseEntity<LoginResponseDto> login(@RequestBody LoginRequestDto requestDto) {
        return ResponseEntity.ok(userService.verifyUser(requestDto));
    }

    @PostMapping("/signup")
    public ResponseEntity<SignupResponseDto> signup(@RequestBody SignupRequestDto requestDto) {
        return ResponseEntity.ok(userService.registerUser(requestDto));
    }

    @PostMapping("/reissue")
    public ResponseEntity<ReissueResponseDto> reissue(@RequestBody ReissueRequestDto requestDto) {
        return ResponseEntity.ok(userService.reissueAccessToken(requestDto));
    }

}
