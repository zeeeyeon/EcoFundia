package com.ssafy.user.dto.response;

import lombok.*;

import java.time.LocalDateTime;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class CouponResponseDto {
    private int couponId;
    private int couponCode;
    private int totalQuantity;
    private int discountAmount;
    private LocalDateTime startDate;
    private LocalDateTime endDate;
}
