package com.ssafy.user.service.impl;

import com.ssafy.user.client.FundingClient;
import com.ssafy.user.client.OrderClient;
import com.ssafy.user.client.SellerClient;
import com.ssafy.user.common.response.PageResponse;
import com.ssafy.user.dto.request.*;
import com.ssafy.user.dto.response.*;
import com.ssafy.user.entity.User;
import com.ssafy.user.common.exception.CustomException;
import com.ssafy.user.mapper.UserMapper;
import com.ssafy.user.service.UserService;
import com.ssafy.user.util.JwtUtil;
import lombok.RequiredArgsConstructor;
import org.springframework.data.redis.core.RedisTemplate;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.web.reactive.function.client.WebClient;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import java.util.Map;
import java.util.concurrent.TimeUnit;
import java.util.stream.Collectors;

import static com.ssafy.user.common.response.ResponseCode.*;

@Service
@RequiredArgsConstructor
public class UserServiceImpl implements UserService {
    private final UserMapper userMapper;
    private final JwtUtil jwtUtil;
    private final RedisTemplate<String, String> redisTemplate;
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
        int userId = user.getUserId();
        if (sellerClient.checkSeller(userId)) {
            role = "SELLER";
        } else {
            role = "USER";
        }
        String accessToken = jwtUtil.generateAccessToken(user, role);
        String refreshToken = jwtUtil.generateRefreshToken(user);

        String hashedRefreshToken = passwordEncoder.encode(refreshToken);
        String key = "refreshToken:" + user.getUserId();
        // RedisTemplate을 사용하여 refresh token 저장 (초 단위 만료 시간)
        redisTemplate.opsForValue().set(key, hashedRefreshToken, jwtUtil.getRefreshTokenExpiration(), TimeUnit.SECONDS);

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
                .build();

        userMapper.insertUser(user);
        User nowUser = userMapper.findByEmail(email);

        String role;
        int userId = nowUser.getUserId();
        if (sellerClient.checkSeller(userId)) {
            role = "SELLER";
        } else {
            role = "USER";
        }
        String accessToken = jwtUtil.generateAccessToken(nowUser, role);
        String refreshToken = jwtUtil.generateRefreshToken(nowUser);

        String hashedRefreshToken = passwordEncoder.encode(refreshToken);
        String key = "refreshToken:" + nowUser.getUserId();
        redisTemplate.opsForValue().set(key, hashedRefreshToken, jwtUtil.getRefreshTokenExpiration(), TimeUnit.SECONDS);

        return new SignupResponseDto(accessToken, refreshToken, nowUser, role);
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

        String key = "refreshToken:" + user.getUserId();
        String storedHashedToken = redisTemplate.opsForValue().get(key);
        if (storedHashedToken == null || !passwordEncoder.matches(refreshToken, storedHashedToken)) {
            throw new CustomException(INVALID_REFRESH_TOKEN);
        }

        // 기존 refresh token 삭제 (토큰 회전)
        redisTemplate.delete(key);

        // role 수정
        String role;
        int userId = user.getUserId();
        if (sellerClient.checkSeller(userId)) {
            role = "SELLER";
        } else {
            role = "USER";
        }
        String newAccessToken = jwtUtil.generateAccessToken(user, role);
        String newRefreshToken = jwtUtil.generateRefreshToken(user);
        String newHashedRefreshToken = passwordEncoder.encode(newRefreshToken);

        // 새로운 refresh token을 Redis에 저장
        redisTemplate.opsForValue().set(key, newHashedRefreshToken, jwtUtil.getRefreshTokenExpiration(), TimeUnit.SECONDS);

        return new ReissueResponseDto(newAccessToken, newRefreshToken);
    }

    @Override
    public GetMyInfoResponseDto getMyInfo(int userId) {
        User user = userMapper.findById(userId);
        if (user == null) {
            throw new CustomException(USER_NOT_FOUND);
        }
        return new GetMyInfoResponseDto(user);
    }

    @Override
    public void updateMyInfo(int userId, UpdateMyInfoRequestDto requestDto) {
        userMapper.updateMyInfo(userId, requestDto.getNickname(), requestDto.getAccount());
    }

    @Override
    public PageResponse<FundingResponseDto> getMyFundingDetails(int userId, int page, int size) {
        List<FundingResponseDto> all = orderClient.getMyFundings(userId);
        return paginate(all, page, size);
    }

    @Override
    public GetMyTotalFundingResponseDto getMyFundingTotal(int userId) {
        return GetMyTotalFundingResponseDto.builder()
                .total(orderClient.getMyTotalFunding(userId))
                .build();
    }

    @Override
    public PageResponse<ReviewResponseDto> getMyReviews(int userId, int page, int size) {
        List<ReviewResponseDto> all = fundingClient.getMyReviews(userId);
        return paginate(all, page, size);
    }

    @Override
    public void postMyReview(int userId, PostReviewRequestDto requestDto) {
        String nickname = userMapper.findNicknameById(userId);
        PostReviewWithNicknameRequestDto dto = PostReviewWithNicknameRequestDto.builder()
                .content(requestDto.getContent())
                .rating(requestDto.getRating())
                .nickname(nickname)
                .fundingId(requestDto.getFundingId())
                .build();

        fundingClient.postMyReview(userId, dto);
    }

    @Override
    public void updateMyReview(int userId, int reviewId, UpdateMyReviewRequestDto requestDto) {
        fundingClient.updateMyReview(userId, reviewId, requestDto);
    }

    @Override
    public void deleteMyReview(int userId, int reviewId) {
        fundingClient.deleteMyReview(userId, reviewId);
    }

    @Override
    public OrderResponseDto createPayment(int userId, CreatePaymentRequestDto requestDto) {
        User user = userMapper.findById(userId);
        return orderClient.createPayment(userId, requestDto.getFundingId(), requestDto.getAmount(), requestDto.getTotalPrice(), user.getSsafyUserKey(), user.getAccount());
    }

    @Override
    public void logout(int userId) {
        String key = "refreshToken:" + userId;
        redisTemplate.delete(key);
    }

    @Override
    public List<Integer> getAgeList(List<GetAgeListRequestDto> dtos) {
        // 10대부터 60대까지 총 6개의 연령대 카운트를 0으로 초기화
        List<Integer> ageGroupCounts = new ArrayList<>(Arrays.asList(0, 0, 0, 0, 0, 0));
        System.out.println("getAgeList 시작!!!");
        // 매퍼에서 결과는 ageGroup(0~5)와 count로 구성된 Map 리스트로 반환됨
        List<Map<String, Object>> results = userMapper.selectAgeGroupCounts(dtos);
        for (Map<String, Object> row : results) {
            int group = (int) row.get("ageGroup");
            // count를 Long에서 int로 변환
//            int count = ((Long) row.get("count")).intValue();
            Long count = (Long) row.get("count");
            if (group >= 0 && group < 6) {
                ageGroupCounts.set(group, count.intValue());
            }
        }
        return ageGroupCounts;
    }

    @Override
    public List<GetSellerFundingDetailOrderUserInfoListResponseDto> getSellerFundingDetailOrderList(GetSellerFundingDetailOrderListRequestDto getSellerFundingDetailOrderListRequestDto) {
        return userMapper.getSellerFundingDetailOrderList(getSellerFundingDetailOrderListRequestDto.getUserIdList()).stream().map(User::toGetSellerFundingDetailOrderUserInfoListResponseDto).collect(Collectors.toList());
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

    private <T> PageResponse<T> paginate(List<T> list, int page, int size) {
        int total = list.size();
        int start = Math.min(page * size, total);
        int end = Math.min(start + size, total);
        List<T> content = list.subList(start, end);
        int totalPages = (int) Math.ceil((double) total / size);
        return new PageResponse<>(content, page, size, total, totalPages);
    }
}
