package com.business.model.entity;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

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
