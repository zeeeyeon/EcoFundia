package com.ssafy.user.service.impl;

import com.ssafy.user.dto.request.LoginRequestDto;
import com.ssafy.user.dto.request.ReissueRequestDto;
import com.ssafy.user.dto.request.SignupRequestDto;
import com.ssafy.user.dto.response.LoginResponseDto;
import com.ssafy.user.dto.response.ReissueResponseDto;
import com.ssafy.user.dto.response.SignupResponseDto;
import com.ssafy.user.entity.User;
import com.ssafy.user.exception.CustomException;
import com.ssafy.user.mapper.UserMapper;
import com.ssafy.user.service.UserService;
import com.ssafy.user.util.JwtUtil;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.web.reactive.function.client.WebClient;

import java.time.LocalDateTime;
import java.util.Map;

@Service
public class UserServiceImpl implements UserService {
    @Autowired
    private UserMapper userMapper;

    @Autowired
    private JwtUtil jwtUtil;

    private static final String GOOGLE_USER_INFO_URL = "https://www.googleapis.com/oauth2/v3/userinfo";

    @Override
    public LoginResponseDto verifyUser(LoginRequestDto requestDto) {
        Map<String, Object> googleUser = getGoogleUserInfo(requestDto.getToken());
        String email = (String) googleUser.get("email");
        User user = userMapper.findByEmail(email);

        if (user == null) {
            throw new CustomException("해당 이메일로 가입된 사용자가 없습니다. 회원가입이 필요합니다.", HttpStatus.NOT_FOUND);
        }

        String role = userMapper.isSeller(user.getUserId()) > 0 ? "SELLER" : "USER";
        String accessToken = jwtUtil.generateAccessToken(user, role);
        String refreshToken = jwtUtil.generateRefreshToken(user);

        return new LoginResponseDto(accessToken, refreshToken, user, role);
    }


    @Override
    public SignupResponseDto registerUser(SignupRequestDto requestDto) {
        Map<String, Object> googleUser = getGoogleUserInfo(requestDto.getToken());
        String email = (String) googleUser.get("email");
        String name = (String) googleUser.get("name");

        User user = User.builder()
                .email(email)
                .name(name)
                .nickname(requestDto.getNickname())
                .gender(requestDto.getGender())
                .age(requestDto.getAge())
                .createdAt(LocalDateTime.now())
                .build();


        userMapper.insertUser(user);

        String role = userMapper.isSeller(user.getUserId()) > 0 ? "SELLER" : "USER";
        String accessToken = jwtUtil.generateAccessToken(user, role);
        String refreshToken = jwtUtil.generateRefreshToken(user);

        return new SignupResponseDto(accessToken, refreshToken, user, role);
    }

    @Override
    public ReissueResponseDto reissueAccessToken(ReissueRequestDto requestDto) {
        String refreshToken = requestDto.getRefreshToken();

        if (refreshToken == null || refreshToken.isEmpty()) {
            throw new CustomException("Refresh Token이 제공되지 않았습니다.", HttpStatus.BAD_REQUEST);
        }

        if (!jwtUtil.validateToken(refreshToken)) {
            throw new CustomException("Refresh Token이 만료되었거나 유효하지 않습니다.", HttpStatus.UNAUTHORIZED);
        }

        String email = jwtUtil.extractEmail(refreshToken);
        User user = userMapper.findByEmail(email);

        if (user == null) {
            throw new CustomException("사용자를 찾을 수 없습니다.", HttpStatus.NOT_FOUND);
        }

        String role = userMapper.isSeller(user.getUserId()) > 0 ? "SELLER" : "USER";
        String newAccessToken = jwtUtil.generateAccessToken(user, role);

        return new ReissueResponseDto(newAccessToken);
    }



    private Map<String, Object> getGoogleUserInfo(String accessToken) {
        String url = GOOGLE_USER_INFO_URL + "?access_token=" + accessToken;
        return WebClient.create()
                .get()
                .uri(url)
                .retrieve()
                .bodyToMono(Map.class)
                .block();
    }
}
