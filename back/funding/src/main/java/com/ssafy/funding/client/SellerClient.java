package com.ssafy.funding.client;

import org.springframework.cloud.openfeign.FeignClient;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@FeignClient(name = "seller")
public interface SellerClient {

    @PostMapping("/api/seller/seller-names")
    Map<Integer, String> getSellerNames(@RequestBody List<Integer> sellerIds);
}