package com.seller.client;

import com.seller.dto.response.GetSellerFundingDetailOrderListResponseDto;
import com.seller.dto.response.GetSellerFundingDetailStatisticsResponseDto;
import com.seller.dto.response.OrderCountResponseDto;
import com.seller.dto.response.OrderInfoResponseDto;
import org.springframework.cloud.openfeign.FeignClient;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@FeignClient(name="order")
public interface OrderClient {
    @GetMapping("/api/order/seller/funding/detail/order/{fundingId}")
    List<GetSellerFundingDetailOrderListResponseDto> getSellerFundingDetailOrderList(@PathVariable("fundingId") int fundingId, @RequestParam(value = "page", defaultValue = "0") int page);

    @GetMapping("/api/order/order-info")
    OrderInfoResponseDto getOrderInfoByFundingId(@RequestParam("fundingId") int fundingId);
    @GetMapping("/api/order/seller/funding/detail/statistics/{fundingId}")
    List<GetSellerFundingDetailStatisticsResponseDto> getSellerFundingDetailStatistics(@PathVariable("fundingId") int fundingId);

    @PostMapping("/api/order/total-order-count")
    List<Integer> getTotalOrderCount(@RequestBody List<Integer> fundingIds);
}
