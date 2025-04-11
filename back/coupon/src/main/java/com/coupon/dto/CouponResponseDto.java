package com.coupon.dto;

import com.coupon.entity.Coupon;

import java.time.LocalDateTime;

public record CouponResponseDto(
        int couponId,
        int couponCode,
        int totalQuantity,
        int discountAmount,
        LocalDateTime startDate,
        LocalDateTime endDate
) {
    public static CouponResponseDto from(Coupon coupon) {
        return new CouponResponseDto(
                coupon.getCouponId(),
                coupon.getCouponCode(),
                coupon.getTotalQuantity(),
                coupon.getDiscountAmount(),
                coupon.getStartDate(),
                coupon.getEndDate()
        );
    }
}
