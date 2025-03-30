package com.order.mapper;

import com.order.dto.order.response.OrderResponseDto;
import com.order.entity.Order;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;

@Mapper
public interface OrderMapper {

    void createOrder(Order order);

    List<Order> getOrders(int userId);

    int getMyOrderPrice(int userId);

    List<Integer> getMyFundingIds(int userId);

    Integer sumOrderAmountByFundingId(@Param("fundingId") int fundingId);
}
