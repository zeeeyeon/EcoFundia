package com.order.entity;

import com.order.dto.funding.response.GetSellerTodayOrderTopThreeIdAndMoneyResponseDto;
import lombok.Builder;
import lombok.Data;
import lombok.Getter;

import java.time.LocalDateTime;

@Data
@Builder
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

    public GetSellerTodayOrderTopThreeIdAndMoneyResponseDto toGetSellerTodayOrderTopThreeIdAndMoneyResponseDto() {
        return GetSellerTodayOrderTopThreeIdAndMoneyResponseDto
                .builder()
                .fundingId(fundingId)
                .totalAmount(totalPriceSumToday)
                .build();
    }
}
