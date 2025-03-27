package com.ssafy.user.client;

import com.ssafy.user.dto.response.FundingResponseDto;
import com.ssafy.user.dto.response.GetMyTotalFundingResponseDto;
import com.ssafy.user.dto.response.OrderResponseDto;
import org.springframework.cloud.openfeign.FeignClient;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RequestParam;

import java.util.List;

@FeignClient(name = "order")
public interface OrderClient {
    @GetMapping("/api/order/funding")
    List<FundingResponseDto> getMyFundings(@RequestHeader("X-User-Id") int userId);

    @GetMapping("/api/order/funding/total")
    int getMyTotalFunding(@RequestHeader("X-User-Id") int userId);

    @PostMapping("/api/order/funding")
    OrderResponseDto createPayment(@RequestHeader("X-User-Id") int userId,
                                   @RequestParam(name="fundingId") int fundingId,
                                   @RequestParam(name="amount") int amount,
                                   @RequestParam(name="totalPrice") int totalPrice,
                                   @RequestParam(name="userKey") String userKey,
                                   @RequestParam(name="userAccount") String userAccount);

}
