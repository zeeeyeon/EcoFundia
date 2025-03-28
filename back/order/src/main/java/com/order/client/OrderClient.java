package com.order.client;

import com.order.dto.funding.response.FundingResponseDto;
import com.order.dto.funding.request.GetSellerTodayOrderCountRequestDto;
import com.order.dto.funding.request.GetSellerTodayOrderTopThreeListRequestDto;
import com.order.dto.funding.response.GetSellerTodayOrderCountResponseDto;
import com.order.dto.funding.response.GetSellerTodayOrderTopThreeIdAndMoneyResponseDto;
import com.order.entity.Order;
import org.springframework.cloud.openfeign.FeignClient;
import org.springframework.web.bind.annotation.*;

import java.util.List;

import java.util.List;

@FeignClient(name="order")
public interface OrderClient {

    // 결제하기
    // @RequestHeader("X-User-Id") int userId 아직 안넣었음
//    @PostMapping("api/order/funding")
//    Order createOrder(@RequestHeader("X-User-Id") int userId,
//                      @RequestParam(name = "fundingId") int fundingId,
//                      @RequestParam(name = "amount") int amount,
//                      @RequestParam(name = "totalPrice") int totalPrice,
//                      @RequestParam(name = "userKey") String userKey,
//                      @RequestParam(name = "userAccount") String userAccount);
//
//
//    // 내 펀딩 내역 조회
//    @GetMapping("api/order/my")
//    Order getOrder(@RequestHeader("X-User-Id") int userId);
//
//    // 내 펀딩 금액 조회
//    @GetMapping("api/order/funding/total")
//    int getMyOrderPrice(@RequestHeader("X-User-Id") int userId);
//
//    // 내가 주문한 펀딩 조회
//    @GetMapping("api/order/my/funding")
//    List<FundingResponseDto> getMyFunding(@RequestHeader("X-User-Id") int userId);
    @PostMapping("api/order/funding")
    Order createOrder(@RequestHeader("X-User-Id") int userId,
                      @RequestParam(name = "fundingId") int fundingId,
                      @RequestParam(name = "amount") int amount,
                      @RequestParam(name = "totalPrice") int totalPrice,
                      @RequestParam(name = "userKey") String userKey,
                      @RequestParam(name = "userAccount") String userAccount);


    // 내 펀딩 내역 조회
    @GetMapping("api/order/my")
    Order getOrder(@RequestParam(name = "userId") int userId);

    @PostMapping("api/order/seller/today-order")
    GetSellerTodayOrderCountResponseDto getSellerTodayOrderCount(@RequestBody GetSellerTodayOrderCountRequestDto getSellerTodayOrderCountRequestDto);
    @PostMapping("api/order/seller/today-order/list")
    List<GetSellerTodayOrderTopThreeIdAndMoneyResponseDto> getSellerTodayOrderTopThreeList(@RequestBody GetSellerTodayOrderTopThreeListRequestDto getSellerTodayOrderTopThreeListRequestDto);

}
