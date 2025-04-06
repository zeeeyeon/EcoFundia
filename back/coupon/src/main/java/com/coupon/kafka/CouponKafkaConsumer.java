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

    @KafkaListener(topics = "coupon-issued", groupId = "coupon")
    public void consume(CouponIssuedEvent event) {
        log.info("Kafka - userId: {}, couponCode: {}", event.userId(), event.couponCode());

        Coupon coupon = couponRepository.findByCouponCode(event.couponCode().intValue())
                .orElseThrow(() -> new CustomException(COUPON_NOT_FOUND));

        CouponIssued issued = event.toEntity(coupon);
        couponIssuedRepository.save(issued);
        log.info("쿠폰 DB 저장 완료 - userId: {}, couponCode: {}", event.userId(), event.couponCode());
    }
}
