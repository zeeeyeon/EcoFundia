package com.coupon.kafka;

import com.coupon.dto.CouponIssuedEvent;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.kafka.core.KafkaTemplate;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;

@Slf4j
@Service
@RequiredArgsConstructor
public class CouponKafkaProducer {

    private final KafkaTemplate<String, CouponIssuedEvent> kafkaTemplate;

    public void send(CouponIssuedEvent event) {
        log.info("카프카 발행 - userId: {}, couponCode: {}", event.userId(), event.couponCode());
        kafkaTemplate.send("coupon", event);
    }
}
