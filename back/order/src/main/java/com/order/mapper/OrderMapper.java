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

    int getSellerTodayOrderCount(@Param("fundingIdList") List<Integer> fundingIdList);
    List<Order> getSellerFundingDetailOrderList(@Param("fundingId") int fundingId, @Param("page") int page);
    List<Order> getSellerMonthAmountStatistics(@Param("fundingIdList") List<Integer> fundingIdList);
    List<Integer> getSellerFundingDetailStatistics(@Param("fundingId") int fundingId);
    List<Integer> getSellerBrandStatistics(@Param("fundingIdList") List<Integer> fundingIdList);
    List<Order> getSellerTodayOrderTopThree(@Param("fundingIdList") List<Integer> fundingIdList);
}
