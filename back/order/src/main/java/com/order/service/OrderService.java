package com.order.service;

import com.order.dto.funding.request.GetSellerTodayOrderCountRequestDto;
import com.order.dto.funding.request.GetSellerTodayOrderTopThreeListRequestDto;
import com.order.dto.funding.response.GetSellerTodayOrderCountResponseDto;
import com.order.dto.funding.response.GetSellerTodayOrderTopThreeIdAndMoneyResponseDto;
import com.order.dto.funding.response.FundingResponseDto;
import com.order.dto.order.response.OrderResponseDto;
import com.order.entity.Order;

import java.util.List;

public interface OrderService {

    Order createOrder(int userId, int fundingId, int quantity, int totalPrice, String userKey, String userAccount);

    List<Order> getOrder(int userId);

    int getMyOrderPrice(int userId);

    List<FundingResponseDto> getMyFunding(int userId);
    GetSellerTodayOrderCountResponseDto getSellerTodayOrderCount(GetSellerTodayOrderCountRequestDto getSellerTodayOrderCountRequestDto);
    List<GetSellerTodayOrderTopThreeIdAndMoneyResponseDto> getSellerTodayOrderTopThreeList(GetSellerTodayOrderTopThreeListRequestDto getSellerTodayOrderTopThreeListRequestDto);
}
