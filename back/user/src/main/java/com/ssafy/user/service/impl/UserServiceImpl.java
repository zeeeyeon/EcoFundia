package com.ssafy.user.service.impl;

import com.ssafy.user.client.FundingClient;
import com.ssafy.user.client.OrderClient;
import com.ssafy.user.client.SellerClient;
import com.ssafy.user.dto.request.*;
import com.ssafy.user.dto.response.*;
import com.ssafy.user.entity.RefreshToken;
import com.ssafy.user.entity.User;
import com.ssafy.user.common.exception.CustomException;
import com.ssafy.user.mapper.UserMapper;
import com.ssafy.user.service.UserService;
import com.ssafy.user.util.JwtUtil;
import feign.FeignException;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.web.reactive.function.client.WebClient;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;

import static com.ssafy.user.common.response.ResponseCode.*;

@Service
@RequiredArgsConstructor
public class UserServiceImpl implements UserService {
    private final UserMapper userMapper;
    private final JwtUtil jwtUtil;
    private final BCryptPasswordEncoder passwordEncoder = new BCryptPasswordEncoder();
    private static final String GOOGLE_USER_INFO_URL = "https://www.googleapis.com/oauth2/v3/userinfo";
    private final FundingClient fundingClient;
    private final OrderClient orderClient;
    private final SellerClient sellerClient;

    @Override
    public LoginResponseDto verifyUser(LoginRequestDto requestDto) {
        Map<String, Object> googleUser = getGoogleUserInfo(requestDto.getToken());
        String email = (String) googleUser.get("email");
        User user = userMapper.findByEmail(email);

        if (user == null) {
            throw new CustomException(USER_NOT_SIGNED_UP);
        }

        // role 수정
        String role;
        String userId = String.valueOf(user.getUserId());
//        if(sellerClient.checkSeller(userId).isSeller()){
//            role = "SELLER";
//        }else{
//            role = "USER";
//        }
        role = "SELLER";
        String accessToken = jwtUtil.generateAccessToken(user, role);
        String refreshToken = jwtUtil.generateRefreshToken(user);

        String hashedRefreshToken = passwordEncoder.encode(refreshToken);
        LocalDateTime issuedAt = LocalDateTime.now();
        LocalDateTime expiresAt = issuedAt.plusDays(7);

        userMapper.insertRefreshToken(user.getUserId(), hashedRefreshToken, issuedAt, expiresAt);

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

        // role 수정
        String role = "SELLER";
        String accessToken = jwtUtil.generateAccessToken(user, role);
        String refreshToken = jwtUtil.generateRefreshToken(user);

        String hashedRefreshToken = passwordEncoder.encode(refreshToken);
        LocalDateTime issuedAt = LocalDateTime.now();
        LocalDateTime expiresAt = issuedAt.plusDays(7);

        userMapper.insertRefreshToken(user.getUserId(), hashedRefreshToken, issuedAt, expiresAt);

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

        List<RefreshToken> storedTokens = userMapper.findRefreshTokensByUserId(user.getUserId());
        RefreshToken validToken = null;
        for (RefreshToken token : storedTokens) {
            if (!token.isExpired() && passwordEncoder.matches(refreshToken, token.getRefreshToken())) {
                validToken = token;
                break;
            }
        }

        if (validToken == null) {
            throw new CustomException(INVALID_REFRESH_TOKEN);
        }

        userMapper.deleteRefreshTokenById(validToken.getTokenId());

        //이거 role 수정해야함
        String role = "SELLER";
        String newAccessToken = jwtUtil.generateAccessToken(user, role);
        String newRefreshToken = jwtUtil.generateRefreshToken(user);
        String newHashedRefreshToken = passwordEncoder.encode(newRefreshToken);
        LocalDateTime newIssuedAt = LocalDateTime.now();
        LocalDateTime newExpiresAt = newIssuedAt.plusDays(7);

        // 기존 토큰 삭제 및 새 토큰 DB 업데이트 (토큰 회전)
        userMapper.insertRefreshToken(user.getUserId(), newHashedRefreshToken, newIssuedAt, newExpiresAt);

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

    @Override
    public void updateMyInfo(UpdateMyInfoRequestDto requestDto) {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        if (authentication == null || !authentication.isAuthenticated()) {
            throw new CustomException(INVALID_ACCESS_TOKEN);
        }
        String email = (String) authentication.getPrincipal();
        int count = userMapper.updateMyInfo(email, requestDto.getNickname(),requestDto.getAccount());

    }

    @Override
    public List<FundingResponseDto> getMyFundingDetails(String userId) {
        try {
            return orderClient.getMyFundings(userId);
        }catch (FeignException e){
            throw new CustomException(INTERNAL_SERVER_ERROR);
        }
    }

    @Override
    public GetMyTotalFundingResponseDto getMyFundingTotal(String userId) {
        try {
            return orderClient.getMyTotalFunding(userId);
        }catch (FeignException e){
            throw new CustomException(INTERNAL_SERVER_ERROR);
        }
    }

    @Override
    public List<ReviewResponseDto> getMyReviews(String userId) {
        try {
            return fundingClient.getMyReviews(userId);
        }catch (FeignException e){
            throw new CustomException(INTERNAL_SERVER_ERROR);
        }
    }

    @Override
    public void postMyReview(String userId, PostReviewRequestDto requestDto) {
        String nickname = userMapper.findNicknameById(Integer.parseInt(userId));
        PostReviewWithNicknameRequestDto dto = PostReviewWithNicknameRequestDto.builder()
                .content(requestDto.getContent())
                .rating(requestDto.getRating())
                .nickname(nickname)
                .fundingId(requestDto.getFundingId())
                .build();
        try {
            fundingClient.postMyReview(userId, dto);
        }catch (FeignException e){
            throw new CustomException(INTERNAL_SERVER_ERROR);
        }
    }

    @Override
    public void updateMyReview(String userId, int reviewId, UpdateMyReviewRequestDto requestDto) {
        try {
            fundingClient.updateMyReview(userId, reviewId, requestDto);
        }catch (FeignException e){
            throw new CustomException(INTERNAL_SERVER_ERROR);
        }
    }

    @Override
    public void deleteMyReview(String userId, int reviewId) {
        try {
            fundingClient.deleteMyReview(userId, reviewId);
        }catch (FeignException e){
            throw new CustomException(INTERNAL_SERVER_ERROR);
        }
    }

    @Override
    public void createPayment(String userId, CreatePaymentRequestDto requestDto) {
        // 테이블정해지고 구현 매퍼에 추가
        String account = null;
        CreateOrderRequestDto dto = CreateOrderRequestDto.builder()
                .fundingId(requestDto.getFundingId())
                .quantity(requestDto.getQuantity())
                .account(account)
                .build();
        try {
            fundingClient.createPayment(userId,dto);
        }catch (FeignException e){
            throw new CustomException(INTERNAL_SERVER_ERROR);
        }
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
