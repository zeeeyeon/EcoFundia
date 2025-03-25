package com.ssafy.user.client;

import com.ssafy.user.dto.response.CheckSellerResponseDto;
import org.springframework.cloud.openfeign.FeignClient;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestHeader;

@FeignClient(name = "seller")
public interface SellerClient {

    @GetMapping("/api/seller/isSeller")
    CheckSellerResponseDto checkSeller(@RequestHeader("X-User-Id") String userId);

}
