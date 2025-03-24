package com.ssafy.funding.client;

import org.springframework.cloud.openfeign.FeignClient;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;

@FeignClient(name = "seller")
public interface SellerClient {
    @GetMapping("/api/seller/sellerName/{sellerId}")
    String getSellerName(@PathVariable("sellerId") int sellerId);
}