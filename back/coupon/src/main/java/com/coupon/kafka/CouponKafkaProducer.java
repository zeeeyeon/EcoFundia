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

    public void send(CouponIssuedEvent event) {
        kafkaTemplate.send("coupon-issued", event);
    }
}
