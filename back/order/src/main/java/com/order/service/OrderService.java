package com.order.service;

import com.order.dto.responseDto.OrderResponseDto;
import com.order.entity.Order;

import java.util.List;

public interface OrderService {

    OrderResponseDto createOrder(int userId, int fundingId, int quantity, int totalPrice);

    List<Order> getOrder(int userId);


}
