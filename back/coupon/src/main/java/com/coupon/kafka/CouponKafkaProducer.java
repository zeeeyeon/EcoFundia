package com.coupon.kafka;

import com.coupon.dto.CouponIssuedEvent;
import lombok.RequiredArgsConstructor;
import org.springframework.kafka.core.KafkaTemplate;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;

@Service
@RequiredArgsConstructor
public class CouponKafkaProducer {

    private final KafkaTemplate<String, CouponIssuedEvent> kafkaTemplate;

    public void send(Long userId, Long couponCode) {
        CouponIssuedEvent event = CouponIssuedEvent.of(userId, couponCode, LocalDateTime.now());
        kafkaTemplate.send("coupon-issued", event);
    }
}
