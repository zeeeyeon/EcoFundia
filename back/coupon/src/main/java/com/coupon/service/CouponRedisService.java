package com.coupon.service;

import com.coupon.common.exception.CustomException;
import com.coupon.dto.CouponIssuedDto;
import com.coupon.entity.Coupon;
import com.coupon.entity.CouponIssued;
import com.coupon.entity.constants.CouponPolicy;
import com.coupon.repository.CouponIssuedRepository;
import com.coupon.repository.CouponRepository;
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

@Slf4j
@Service
@RequiredArgsConstructor
public class CouponRedisService {

    private final RedisTemplate<String, Object> redisTemplate;
    private final CouponRepository couponRepository;
    private final CouponIssuedRepository couponIssuedRepository;

    public boolean issueCoupon(int userId, int couponCode) throws IOException {
        String userKey = "coupon:issued:" + userId;
        String countKey = "coupon:count:" + couponCode;

        ClassPathResource resource = new ClassPathResource("scripts/coupon_issue.lua");
        String script = new String(resource.getInputStream().readAllBytes(), StandardCharsets.UTF_8);


        DefaultRedisScript<Long> redisScript = new DefaultRedisScript<>(script, Long.class);

        long ttlSeconds = getTimeToLive();

        List<String> keys = List.of(userKey, countKey);
        Long result = redisTemplate.execute(redisScript, keys,
                String.valueOf(CouponPolicy.DAILY_COUPON_QUANTITY), String.valueOf(ttlSeconds));

        if (result == null) return false;

        switch (result.intValue()) {
            case -1 -> throw new CustomException(COUPON_ALREADY_ISSUED);
            case 0 -> throw new CustomException(COUPON_OUT_OF_STOCK);
            case 1 -> {
                saveCouponToDB(userId, couponCode);
                return true;
            }

            default -> throw new IllegalStateException("Unexpected Redis result: " + result);
        }
    }

    private void saveCouponToDB(int userId, int couponCode) {
        Coupon coupon = couponRepository.findByCouponCodeWithLock(couponCode)
                .orElseThrow(() -> {
                    log.warn("쿠폰 코드 [{}] 존재하지 않음", couponCode);
                    return new CustomException(COUPON_NOT_FOUND);
                });

        CouponIssued issued = CouponIssuedDto.toEntity(coupon, userId);
        couponIssuedRepository.save(issued);
    }

    private long getTimeToLive() {
        LocalDateTime now = LocalDateTime.now(ZoneId.of("Asia/Seoul"));
        LocalDateTime endOfDay = now.toLocalDate().atTime(LocalTime.MAX);
        return Duration.between(now, endOfDay).getSeconds();
    }
}