package com.ssafy.funding.model.entity;

import lombok.*;

import java.time.LocalDate;

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
    private LocalDate createdAt;
    private LocalDate updatedAt;
}
