package com.order.controller;

import com.order.dto.funding.response.FundingResponseDto;
import com.order.dto.funding.request.GetSellerTodayOrderCountRequestDto;
import com.order.dto.funding.request.GetSellerTodayOrderTopThreeListRequestDto;
import com.order.dto.funding.response.GetSellerTodayOrderCountResponseDto;
import com.order.dto.funding.response.GetSellerTodayOrderTopThreeIdAndMoneyResponseDto;
import com.order.dto.order.response.OrderResponseDto;
import com.order.entity.Order;
import com.order.service.OrderService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.List;


@RestController
@RequestMapping("/api/order")
@RequiredArgsConstructor
public class OrderController {

    private final OrderService orderService;

    // 결제 하기
    @PostMapping("/funding")
    public OrderResponseDto createOrder(@RequestHeader("X-User-Id") int userId,
                                        @RequestParam(name = "fundingId") int fundingId,
                                        @RequestParam(name = "quantity") int quantity,
                                        @RequestParam(name = "totalPrice") int totalPrice,
                                        @RequestParam(name = "userKey") String userKey,
                                        @RequestParam(name = "userAccount") String userAccount
    ){
        Order response = orderService.createOrder(userId, fundingId, quantity, totalPrice, userKey, userAccount);

        return OrderResponseDto.toDto(response);
    }

    @GetMapping("/my")
    public List<Order> getOrder(@RequestParam(name = "userId") int userId){
        return orderService.getOrder(userId);
    }

    // 내가 주문한 펀딩 조회
    @GetMapping("/funding")
    public List<FundingResponseDto> getMyFunding(@RequestHeader("X-User-Id") int userId){
        List<FundingResponseDto> fundingList = orderService.getMyFunding(userId);
        return fundingList;
    }

    // 내 펀딩 내역 조회
    @GetMapping("/funding/total")
    public int getMyOrderPrice(@RequestHeader("X-User-Id") int userId){
        int price = orderService.getMyOrderPrice(userId);
        return price;
    }


    @PostMapping("/seller/today-order")
    public GetSellerTodayOrderCountResponseDto getSellerTodayOrderCount(@RequestBody GetSellerTodayOrderCountRequestDto getSellerTodayOrderCountRequestDto) {
        return orderService.getSellerTodayOrderCount(getSellerTodayOrderCountRequestDto);
    }

    @PostMapping("/seller/today-order/list")
    public List<GetSellerTodayOrderTopThreeIdAndMoneyResponseDto> getSellerTodayOrderTopThreeList(@RequestBody GetSellerTodayOrderTopThreeListRequestDto getSellerTodayOrderTopThreeListRequestDto) {
        return orderService.getSellerTodayOrderTopThreeList(getSellerTodayOrderTopThreeListRequestDto);
    }

}
