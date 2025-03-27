package com.order.client;

import com.order.entity.Order;
import org.springframework.cloud.openfeign.FeignClient;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RequestParam;

import java.util.List;

@FeignClient(name="order")
public interface OrderClient {

    // 결제하기
    // @RequestHeader("X-User-Id") int userId 아직 안넣었음
    @PostMapping("api/order/funding")
    Order createOrder(@RequestHeader("X-User-Id") int userId,
                      @RequestParam(name = "fundingId") int fundingId,
                      @RequestParam(name = "amount") int amount,
                      @RequestParam(name = "totalPrice") int totalPrice,
                      @RequestParam(name = "userKey") String userKey,
                      @RequestParam(name = "userAccount") String userAccount);


    // 내 펀딩 내역 조회
    @GetMapping("api/order/my")
    Order getOrder(@RequestHeader("X-User-Id") int userId);

    // 내 펀딩 금액 조회
    @GetMapping("api/order/funding/total")
    int getMyOrderPrice(@RequestHeader("X-User-Id") int userId);

    // 내가 주문한 펀딩 조회
    @GetMapping("api/order/funding")
    List<Integer> getMyFunding(@RequestHeader("X-User-Id") int userId);
}
