package com.coupon.dto;

import com.coupon.entity.Coupon;
import com.coupon.entity.CouponIssued;

import java.time.LocalDateTime;

public record CouponIssuedEvent(
        Long userId,
        Long couponId,
        LocalDateTime issuedAt
) {
    public static CouponIssuedEvent of(Long userId, Long couponId, LocalDateTime issuedAt) {
        return new CouponIssuedEvent(userId, couponId, issuedAt);
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
