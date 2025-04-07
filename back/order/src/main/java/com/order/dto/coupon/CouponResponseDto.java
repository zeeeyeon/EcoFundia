package com.order.dto.coupon;

import java.time.LocalDateTime;

public record CouponResponseDto(
        int couponId,
        int couponCode,
        int totalQuantity,
        int discountAmount,
        LocalDateTime startDate,
        LocalDateTime endDate
) {
}
