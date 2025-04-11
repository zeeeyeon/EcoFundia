package com.coupon.service;

import com.coupon.common.exception.CustomException;
import com.coupon.dto.CouponIssuedDto;
import com.coupon.entity.Coupon;
import com.coupon.entity.CouponIssued;
import com.coupon.repository.CouponIssuedRepository;
import com.coupon.repository.CouponRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.redis.core.RedisTemplate;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

import static com.coupon.common.response.ResponseCode.COUPON_NOT_FOUND;

@Slf4j
@Component
@RequiredArgsConstructor
public class CouponIssueScheduler {

    private final RedisTemplate<String, Object> redisTemplate;
    private final CouponRepository couponRepository;
    private final CouponIssuedRepository couponIssuedRepository;

    @Scheduled(fixedDelay = 100)
    public void processCouponIssued() {
        String queueKey = "coupon:queue";

        while (Boolean.TRUE.equals(redisTemplate.hasKey(queueKey))) {
            String data = (String) redisTemplate.opsForList().leftPop(queueKey);

            if (data == null) break;

            String[] parts = data.split(":");
            int userId = Integer.parseInt(parts[0]);
            int couponCode = Integer.parseInt(parts[1]);

            saveCouponToDB(userId, couponCode);
        }
    }

    @Scheduled(fixedDelay = 500)
    public void retryFailedCouponIssued() {
        String retryQueueKey = "coupon:queue:retry";

        while (Boolean.TRUE.equals(redisTemplate.hasKey(retryQueueKey))) {
            String data = (String) redisTemplate.opsForList().leftPop(retryQueueKey);

            if (data == null) break;

            String[] parts = data.split(":");
            int userId = Integer.parseInt(parts[0]);
            int couponCode = Integer.parseInt(parts[1]);

            try {
                saveCouponToDB(userId, couponCode);
            } catch (Exception e) {
                log.error("재시도 실패 - 사용자: {}, 쿠폰: {} / 에러: {}", userId, couponCode, e.getMessage());
                redisTemplate.opsForList().rightPush(retryQueueKey, data);
            }
        }
    }

    private void saveCouponToDB(int userId, int couponCode) {
        Coupon coupon = couponRepository.findByCouponCode(couponCode)
                .orElseThrow(() -> {
                    log.warn("쿠폰 코드 [{}] 존재하지 않음", couponCode);
                    return new CustomException(COUPON_NOT_FOUND);
                });

        CouponIssued issued = CouponIssuedDto.toEntity(coupon, userId);
        couponIssuedRepository.save(issued);
        log.debug("쿠폰 DB 저장 완료 - 사용자: {}, 쿠폰: {}", userId, couponCode);
    }
}
