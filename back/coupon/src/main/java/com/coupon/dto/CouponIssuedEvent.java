package com.coupon.dto;

import com.coupon.entity.Coupon;
import com.coupon.entity.CouponIssued;
import com.fasterxml.jackson.annotation.JsonFormat;

import java.time.LocalDateTime;

public record CouponIssuedEvent(
        Long userId,
        Long couponCode,
        @JsonFormat(shape = JsonFormat.Shape.STRING, pattern = "yyyy-MM-dd'T'HH:mm:ss")
        LocalDateTime issuedAt
) {
    public static CouponIssuedEvent of(Long userId, Long couponCode, LocalDateTime issuedAt) {
        return new CouponIssuedEvent(userId, couponCode, issuedAt);
    }

    public CouponIssued toEntity(Coupon coupon) {
        return CouponIssued.builder()
                .userId(userId.intValue())
                .coupon(coupon)
                .isUsed(false)
                .usedAt(null)
                .build();
    }
}
