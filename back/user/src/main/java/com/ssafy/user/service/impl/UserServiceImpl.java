package com.ssafy.user.service.impl;

import com.ssafy.user.dto.request.LoginRequestDto;
import com.ssafy.user.dto.request.SignupRequestDto;
import com.ssafy.user.dto.response.LoginResponseDto;
import com.ssafy.user.dto.response.SignupResponseDto;
import com.ssafy.user.entity.User;
import com.ssafy.user.mapper.UserMapper;
import com.ssafy.user.service.UserService;
import com.ssafy.user.util.JwtUtil;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;

import java.time.LocalDateTime;
import java.util.Map;

@Service
public class UserServiceImpl implements UserService {
    @Autowired
    private UserMapper userMapper;

    @Autowired
    private JwtUtil jwtUtil;

    @Autowired
    private RestTemplate restTemplate;

    private static final String GOOGLE_USER_INFO_URL = "https://www.googleapis.com/oauth2/v3/userinfo";

    @Override
    public LoginResponseDto verifyUser(LoginRequestDto requestDto) {
        Map<String, Object> googleUser = getGoogleUserInfo(requestDto.getToken());
        String email = (String) googleUser.get("email");
        User user = userMapper.findByEmail(email);

        if (user != null) {
            String role = userMapper.isSeller(user.getUserId()) > 0 ? "SELLER" : "USER";
            String accessToken = jwtUtil.generateAccessToken(user, role);
            String refreshToken = jwtUtil.generateRefreshToken(user);

            return new LoginResponseDto(accessToken, refreshToken, user, role);
        }

        return new LoginResponseDto(null, null, null, null);
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

    private Map<String, Object> getGoogleUserInfo(String accessToken) {
        String url = GOOGLE_USER_INFO_URL + "?access_token=" + accessToken;
        return restTemplate.getForObject(url, Map.class);
    }
}
