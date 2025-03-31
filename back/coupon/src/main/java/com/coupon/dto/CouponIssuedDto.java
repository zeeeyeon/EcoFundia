package com.coupon.dto;

import com.coupon.entity.Coupon;
import com.coupon.entity.CouponIssued;

public record CouponIssuedDto(
        int couponId,
        int userId
) {
    public static CouponIssued toEntity(Coupon coupon, int userId) {
        return CouponIssued.builder()
                .coupon(coupon)
                .userId(userId)
                .isUsed(false)
                .build();
    }
}