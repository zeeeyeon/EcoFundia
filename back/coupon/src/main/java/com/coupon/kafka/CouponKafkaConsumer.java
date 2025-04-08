package com.coupon.kafka;

import com.coupon.common.exception.CustomException;
import com.coupon.dto.CouponIssuedEvent;
import com.coupon.entity.Coupon;
import com.coupon.entity.CouponIssued;
import com.coupon.repository.CouponIssuedRepository;
import com.coupon.repository.CouponRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.kafka.annotation.KafkaListener;
import org.springframework.stereotype.Component;

import static com.coupon.common.response.ResponseCode.COUPON_NOT_FOUND;

@Slf4j
@Component
@RequiredArgsConstructor
public class CouponKafkaConsumer {

    private final CouponRepository couponRepository;
    private final CouponIssuedRepository couponIssuedRepository;

    @KafkaListener(topics = "coupon", groupId = "coupon-v2")
    public void consume(CouponIssuedEvent event) {
        try {
            Coupon coupon = couponRepository.findByCouponCode(event.couponCode().intValue())
                    .orElseThrow(() -> new CustomException(COUPON_NOT_FOUND));

            if (couponIssuedRepository.existsByUserIdAndCoupon(event.userId(), coupon)) {
                log.warn("이미 발급된 쿠폰입니다 - userId: {}, couponCode: {}", event.userId(), event.couponCode());
                return;
            }

            CouponIssued issued = event.toEntity(coupon);
            couponIssuedRepository.save(issued);
            log.info("쿠폰 DB 저장 완료 - userId: {}, couponCode: {}", event.userId(), event.couponCode());
        } catch (Exception e) {
            log.error("Consumer 오류 - userId: {}, couponCode: {}, error: {}",
                    event.userId(), event.couponCode(), e.getMessage(), e);
        }
    }

}
