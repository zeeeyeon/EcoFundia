package com.coupon.dto;

import com.coupon.entity.CouponIssued;
import com.coupon.entity.CouponUsage;

import java.time.LocalDateTime;

public record CouponUsageDto(
        int issuedId,
        int fundingId
) {
    public static CouponUsage toEntity(CouponIssued issued, int fundingId) {
        return CouponUsage.builder()
                .couponIssued(issued)
                .fundingId(fundingId)
                .usedAt(LocalDateTime.now())
                .build();
    }
}