package com.order.entity;

import com.order.dto.funding.response.GetSellerTodayOrderTopThreeIdAndMoneyResponseDto;
import com.order.dto.seller.response.GetSellerMonthAmountStatisticsResponseDto;
import lombok.*;

import java.time.LocalDateTime;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class Order {

    private int orderId;
    private int userId;
    private int fundingId;
    private int amount;
    private int quantity;
    private int totalPrice;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
    private int totalPriceSumToday;

    private String month;
    private int totalAmount;

    public GetSellerTodayOrderTopThreeIdAndMoneyResponseDto toGetSellerTodayOrderTopThreeIdAndMoneyResponseDto() {
        return GetSellerTodayOrderTopThreeIdAndMoneyResponseDto
                .builder()
                .fundingId(fundingId)
                .totalAmount(totalPriceSumToday)
                .build();
    }

    public GetSellerMonthAmountStatisticsResponseDto toGetSellerMonthAmountStatisticsResponseDto() {
        return GetSellerMonthAmountStatisticsResponseDto
                .builder()
                .month(month)
                .totalAmount(totalAmount)
                .build();
    }
}
