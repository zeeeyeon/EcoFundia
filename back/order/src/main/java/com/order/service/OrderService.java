package com.order.service;

import com.order.dto.order.response.OrderResponseDto;
import com.order.entity.Order;

import java.util.List;

public interface OrderService {

    Order createOrder(int userId, int fundingId, int quantity, int totalPrice, String userKey, String userAccount);

    List<Order> getOrder(int userId);


}
