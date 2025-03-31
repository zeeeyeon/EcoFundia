package com.order.service;

import com.order.dto.funding.request.GetSellerTodayOrderCountRequestDto;
import com.order.dto.funding.request.GetSellerTodayOrderTopThreeListRequestDto;
import com.order.dto.funding.response.*;
import com.order.dto.order.response.OrderResponseDto;
import com.order.dto.seller.response.GetSellerMonthAmountStatisticsResponseDto;
import com.order.entity.Order;

import java.util.List;

public interface OrderService {

    Order createOrder(int userId, int fundingId, int quantity, int totalPrice, String userKey, String userAccount);

    List<Order> getOrder(int userId);

    int getMyOrderPrice(int userId);

    List<FundingResponseDto> getMyFunding(int userId);
    GetSellerTodayOrderCountResponseDto getSellerTodayOrderCount(GetSellerTodayOrderCountRequestDto getSellerTodayOrderCountRequestDto);
    List<GetSellerTodayOrderTopThreeIdAndMoneyResponseDto> getSellerTodayOrderTopThreeList(GetSellerTodayOrderTopThreeListRequestDto getSellerTodayOrderTopThreeListRequestDto);
    List<GetSellerFundingDetailOrderListResponseDto> getSellerFundingDetailOrderList(int fundingId, int page);
    List<GetSellerMonthAmountStatisticsResponseDto> getSellerMonthAmountStatistics(List<Integer> fundingIdList);
    List<GetSellerFundingDetailStatisticsResponseDto> getSellerFundingDetailStatistics(int fundingId);
    List<Integer> getSellerBrandStatistics(List<Integer> userIdList);
}
