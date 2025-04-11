package com.coupon.dto;

import com.coupon.entity.CouponIssued;
import com.coupon.entity.CouponUsage;

import java.time.LocalDateTime;

public record CouponUsageRequestDto(
        int userId,
        int fundingId,
        int couponId
) {
    public CouponUsage toEntity(CouponIssued issuedCoupon) {
        return CouponUsage.builder()
                .couponIssued(issuedCoupon)
                .fundingId(fundingId)
                .usedAt(LocalDateTime.now())
                .build();
    }
}
