package com.coupon.service;

import com.coupon.common.exception.CustomException;
import com.coupon.dto.CouponIssuedEvent;
import com.coupon.entity.Coupon;
import com.coupon.entity.constants.CouponPolicy;
import com.coupon.kafka.CouponKafkaProducer;
import com.coupon.repository.CouponIssuedRepository;
import com.coupon.repository.CouponRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.io.IOException;
import java.time.Duration;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.time.ZoneId;

import static com.coupon.common.response.ResponseCode.*;

@Service
@RequiredArgsConstructor
@Slf4j
public class CouponRedisService {

    private final CouponExecutor couponExecutor;
    private final CouponKafkaProducer couponKafkaProducer;
    private final CouponRepository couponRepository;
    private final CouponIssuedRepository couponIssuedRepository;

    public void issueCoupon(int userId, int couponCode) throws IOException {
        Coupon coupon = couponRepository.findByCouponCode(couponCode)
                .orElseThrow(() -> new CustomException(COUPON_NOT_FOUND));

        coupon.validateIssuable();

        if (couponIssuedRepository.existsByUserIdAndCoupon(userId, coupon)) throw new CustomException(COUPON_ALREADY_ISSUED);

        LocalTime now = LocalTime.now(ZoneId.of("Asia/Seoul"));
        if (now.isBefore(LocalTime.of(10, 0))) throw new CustomException(COUPON_NOT_YET_TIME);

        String userKey = "coupon:issued:" + userId + ":" + couponCode;
        String countKey = "coupon:count:" + couponCode;
        long ttlSeconds = getTimeToLive();

        long result = couponExecutor.executeCoupon(userKey, countKey, String.valueOf(CouponPolicy.DAILY_COUPON_QUANTITY), String.valueOf(ttlSeconds));

        if (result == -1) throw new CustomException(COUPON_ALREADY_ISSUED);
        if (result == 0) throw new CustomException(COUPON_OUT_OF_STOCK);

        couponKafkaProducer.send(
                CouponIssuedEvent.of(userId, couponCode, LocalDateTime.now())
        );
    }

    private long getTimeToLive() {
        LocalDateTime now = LocalDateTime.now(ZoneId.of("Asia/Seoul"));
        LocalDateTime endOfDay = now.toLocalDate().atTime(LocalTime.MAX);
        return Duration.between(now, endOfDay).getSeconds();
    }
}