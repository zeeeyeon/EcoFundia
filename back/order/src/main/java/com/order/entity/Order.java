package com.order.entity;

import java.time.LocalDateTime;

public class Order {

    private int orderId;
    private int userId;
    private int fundingId;
    private int amount;
    private int quantity;
    private int totalPrice;
    private LocalDateTime createAt;
    private LocalDateTime updateAt;

}
