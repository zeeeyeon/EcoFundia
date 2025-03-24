package com.order.mapper;

import com.order.dto.order.response.OrderResponseDto;
import com.order.entity.Order;
import org.apache.ibatis.annotations.Mapper;

import java.util.List;

@Mapper
public interface OrderMapper {

    OrderResponseDto createOrder(int userId, int fundingId, int amount, int totalPrice, int quantity);

    List<Order> getOrders(int userId);
}
