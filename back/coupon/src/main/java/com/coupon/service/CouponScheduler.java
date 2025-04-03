package com.coupon.service;

import com.coupon.dto.CouponIssuedDto;
import com.coupon.entity.Coupon;
import com.coupon.entity.constants.CouponPolicy;
import com.coupon.repository.CouponRepository;
import lombok.RequiredArgsConstructor;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.ZoneId;
import java.time.format.DateTimeFormatter;

@Component
@RequiredArgsConstructor
public class CouponScheduler {

    private final CouponRepository couponRepository;

    @Scheduled(cron = "0 0 9 * * ?")
    public void createTodayCoupon() {
        int code = generateTodayCode();
        if (couponRepository.existsById(code)) return;

        LocalDateTime now = LocalDateTime.now(ZoneId.of("Asia/Seoul"));
        LocalDateTime endOfDay = now.withHour(23).withMinute(59).withSecond(59);

        Coupon coupon = Coupon.create(code, CouponPolicy.DAILY_COUPON_QUANTITY, CouponPolicy.DAILY_COUPON_DISCOUNT, now, endOfDay);
        couponRepository.save(coupon);
    }

    private int generateTodayCode() {
        LocalDate today = LocalDate.now(ZoneId.of("Asia/Seoul"));
        return Integer.parseInt(today.format(DateTimeFormatter.ofPattern("yyMMdd")));
    }
}
