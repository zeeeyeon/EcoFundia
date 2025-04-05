package com.coupon.service;

import com.coupon.common.exception.CustomException;
import com.coupon.dto.CouponIssuedDto;
import com.coupon.entity.Coupon;
import com.coupon.entity.CouponIssued;
import com.coupon.entity.constants.CouponPolicy;
import com.coupon.repository.CouponIssuedRepository;
import com.coupon.repository.CouponRepository;
import jakarta.annotation.PostConstruct;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.core.io.ClassPathResource;
import org.springframework.data.redis.core.RedisTemplate;
import org.springframework.data.redis.core.script.DefaultRedisScript;
import org.springframework.stereotype.Service;

import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.time.Duration;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.time.ZoneId;
import java.util.List;

import static com.coupon.common.response.ResponseCode.*;
import static com.coupon.common.util.CouponUtil.generateTodayCode;

@Service
@RequiredArgsConstructor
@Slf4j
public class CouponRedisService {

    private final RedisTemplate<String, Object> redisTemplate;
    private final CouponExecutor couponExecutor;

    public void issueCoupon(int userId, int couponCode) throws IOException {
        String userKey = "coupon:issued:" + userId + ":" + couponCode;
        String countKey = "coupon:count:" + couponCode;
        long ttlSeconds = getTimeToLive();

        long result = couponExecutor.executeCoupon(userKey, countKey, String.valueOf(CouponPolicy.DAILY_COUPON_QUANTITY), String.valueOf(ttlSeconds));

        log.debug("쿠폰 발급 시도 - 사용자: {}, 쿠폰: {}, 일일한도: {}, TTL: {}초",
                userId, couponCode, CouponPolicy.DAILY_COUPON_QUANTITY, ttlSeconds);

        if (result == -1) throw new CustomException(COUPON_ALREADY_ISSUED);
        if (result == 0) throw new CustomException(COUPON_OUT_OF_STOCK);
        if (result == 1) {
            String redisQueueKey = "coupon:queue";
            String issuedData = userId + ":" + couponCode;
            redisTemplate.opsForList().rightPush(redisQueueKey, issuedData);
        }
    }


    private long getTimeToLive() {
        LocalDateTime now = LocalDateTime.now(ZoneId.of("Asia/Seoul"));
        LocalDateTime endOfDay = now.toLocalDate().atTime(LocalTime.MAX);
        return Duration.between(now, endOfDay).getSeconds();
    }
}