package com.ssafy.user.service.impl;

import com.ssafy.user.dto.request.LoginRequestDto;
import com.ssafy.user.dto.request.ReissueRequestDto;
import com.ssafy.user.dto.request.SignupRequestDto;
import com.ssafy.user.dto.response.GetMyInfoResponseDto;
import com.ssafy.user.dto.response.LoginResponseDto;
import com.ssafy.user.dto.response.ReissueResponseDto;
import com.ssafy.user.dto.response.SignupResponseDto;
import com.ssafy.user.entity.User;
import com.ssafy.user.common.exception.CustomException;
import com.ssafy.user.mapper.UserMapper;
import com.ssafy.user.service.UserService;
import com.ssafy.user.util.JwtUtil;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;
import org.springframework.web.reactive.function.client.WebClient;

import java.time.LocalDateTime;
import java.util.Map;

import static com.ssafy.user.common.response.ResponseCode.*;

@Service
@RequiredArgsConstructor
public class UserServiceImpl implements UserService {
    private final UserMapper userMapper;
    private final JwtUtil jwtUtil;
    private static final String GOOGLE_USER_INFO_URL = "https://www.googleapis.com/oauth2/v3/userinfo";

    @Override
    public LoginResponseDto verifyUser(LoginRequestDto requestDto) {
        Map<String, Object> googleUser = getGoogleUserInfo(requestDto.getToken());
        String email = (String) googleUser.get("email");
        User user = userMapper.findByEmail(email);

        if (user == null) {
            throw new CustomException(USER_NOT_SIGNED_UP);
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
            throw new CustomException(MISSING_REFRESH_TOKEN);
        }

        if (!jwtUtil.validateToken(refreshToken)) {
            throw new CustomException(INVALID_REFRESH_TOKEN);
        }

        String email = jwtUtil.extractEmail(refreshToken);
        User user = userMapper.findByEmail(email);

        if (user == null) {
            throw new CustomException(USER_NOT_FOUND);
        }

        String role = userMapper.isSeller(user.getUserId()) > 0 ? "SELLER" : "USER";
        String newAccessToken = jwtUtil.generateAccessToken(user, role);
        String newRefreshToken = jwtUtil.generateRefreshToken(user);

        return new ReissueResponseDto(newAccessToken,newRefreshToken);
    }

    @Override
    public GetMyInfoResponseDto getMyInfo() {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        if (authentication == null || !authentication.isAuthenticated()) {
            throw new CustomException(INVALID_ACCESS_TOKEN);
        }
        String email = (String) authentication.getPrincipal();
        User user = userMapper.findByEmail(email);
        if (user == null) {
            throw new CustomException(USER_NOT_FOUND);
        }
        return new GetMyInfoResponseDto(user);
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
