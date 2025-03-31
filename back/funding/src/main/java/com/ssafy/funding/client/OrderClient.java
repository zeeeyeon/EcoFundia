package com.ssafy.funding.client;

import com.ssafy.funding.dto.seller.request.GetSellerTodayOrderCountRequestDto;
import com.ssafy.funding.dto.seller.request.GetSellerTodayOrderTopThreeListRequestDto;
import com.ssafy.funding.dto.seller.response.GetSellerMonthAmountStatisticsResponseDto;
import com.ssafy.funding.dto.seller.response.GetSellerTodayOrderCountResponseDto;
import com.ssafy.funding.dto.seller.response.GetSellerTodayOrderTopThreeIdAndMoneyResponseDto;
import org.springframework.cloud.openfeign.FeignClient;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;

import java.util.List;

@FeignClient(name = "order")
public interface OrderClient {
    @PostMapping("api/order/seller/today-order")
    GetSellerTodayOrderCountResponseDto getSellerTodayOrderCount(@RequestBody GetSellerTodayOrderCountRequestDto getSellerTodayOrderCountRequestDto);
    @PostMapping("api/order/seller/today-order/list")
    List<GetSellerTodayOrderTopThreeIdAndMoneyResponseDto> getSellerTodayOrderTopThreeList(@RequestBody GetSellerTodayOrderTopThreeListRequestDto getSellerTodayOrderTopThreeListRequestDto);
    @PostMapping("/api/order/seller/month-amount-statistics")
    List<GetSellerMonthAmountStatisticsResponseDto> getSellerMonthAmountStatistics(@RequestBody List<Integer> fundingIdList);
    @PostMapping("/api/order/seller/brand-statistics")
    List<Integer> getSellerBrandStatistics(@RequestBody List<Integer> fundingIdList);
}
