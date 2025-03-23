package com.order.service.impl;

import com.order.dto.responseDto.OrderResponseDto;
import com.order.entity.Order;
import com.order.mapper.OrderMapper;
import com.order.service.OrderService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
@RequiredArgsConstructor
public class OrderServiceImpl implements OrderService {

    private final OrderMapper orderMapper;

    // 결제 하기
    public OrderResponseDto createOrder(int userId, int fundingId, int quantity, int totalPrice){
        int amount = totalPrice / quantity;

        OrderResponseDto orderResponseDto = orderMapper.createOrder(userId, fundingId, quantity, amount);
        return orderResponseDto;
    }

    public List<Order> getOrder(int userId){
        List<Order> orders = orderMapper.getOrders(userId);
        return orders;
    }
}
