package com.seller.client;

import com.seller.dto.response.OrderInfoResponseDto;
import org.springframework.cloud.openfeign.FeignClient;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;

@FeignClient(name = "order")
public interface OrderClient {

    @GetMapping("/api/order/order-info")
    OrderInfoResponseDto getOrderInfoByFundingId(@RequestParam("fundingId") int fundingId);
}
