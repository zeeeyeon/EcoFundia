package com.order.dto.order.response;

import lombok.Data;

import java.time.LocalDateTime;

@Data
public class OrderResponseDto {

    private int orderId;
    private int userId;
    private int fundingId;
    private int amount;
    private int quantity;
    private int totalPrice;
    private LocalDateTime createdAt;
}
