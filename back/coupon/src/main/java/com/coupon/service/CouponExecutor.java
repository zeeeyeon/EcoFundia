package com.coupon.service;

import com.coupon.entity.constants.CouponPolicy;
import jakarta.annotation.PostConstruct;
import lombok.RequiredArgsConstructor;
import org.springframework.core.io.ClassPathResource;
import org.springframework.data.redis.core.RedisTemplate;
import org.springframework.data.redis.core.script.DefaultRedisScript;
import org.springframework.stereotype.Component;

import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.util.Arrays;
import java.util.List;

import static com.coupon.common.util.CouponUtil.generateTodayCode;

@Component
@RequiredArgsConstructor
public class CouponExecutor {
    private final RedisTemplate<String, Object> redisTemplate;

    @PostConstruct
    public void initializeCouponCounts() {
        int todayCode = generateTodayCode();
        String countKey = "coupon:count:" + todayCode;
        redisTemplate.opsForValue().setIfAbsent(countKey, "0");
    }

    public long executeCoupon(String userKey, String couponKey, String totalQuantity, String ttlSeconds) throws IOException {
        ClassPathResource resource = new ClassPathResource("scripts/coupon_issue.lua");
        String script = new String(resource.getInputStream().readAllBytes(), StandardCharsets.UTF_8);

        DefaultRedisScript<Long> redisScript = new DefaultRedisScript<>(script, Long.class);

        List<String> keys = Arrays.asList(userKey, couponKey);
        return redisTemplate.execute(redisScript, keys, totalQuantity, ttlSeconds);
    }
}
