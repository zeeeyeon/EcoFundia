package com.coupon.dto;

import com.coupon.entity.Coupon;
import com.coupon.entity.CouponIssued;
import com.fasterxml.jackson.annotation.JsonFormat;
import com.fasterxml.jackson.annotation.JsonProperty;

import java.time.LocalDateTime;

public record CouponIssuedEvent(
        @JsonProperty("userId") Integer userId,
        @JsonProperty("couponCode") Integer couponCode,
        @JsonFormat(shape = JsonFormat.Shape.STRING, pattern = "yyyy-MM-dd'T'HH:mm:ss")
        @JsonProperty("issuedAt") LocalDateTime issuedAt
) {
    public static CouponIssuedEvent of(Integer userId, Integer couponCode, LocalDateTime issuedAt) {
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
