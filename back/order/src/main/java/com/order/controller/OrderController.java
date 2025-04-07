package com.order.controller;

import com.order.dto.funding.response.*;
import com.order.dto.funding.request.GetSellerTodayOrderCountRequestDto;
import com.order.dto.funding.request.GetSellerTodayOrderTopThreeListRequestDto;
import com.order.dto.order.response.OrderResponseDto;
import com.order.dto.seller.response.GetSellerMonthAmountStatisticsResponseDto;
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
                                        @RequestParam(name = "userAccount") String userAccount,
                                        @RequestParam(name = "couponId", required = false) Integer couponId
    ){
        Order response = orderService.createOrder(userId, fundingId, quantity, totalPrice, userKey, userAccount, couponId);

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

    @GetMapping("/seller/funding/detail/order/{fundingId}")
    public List<GetSellerFundingDetailOrderListResponseDto> getSellerFundingDetailOrderList(@PathVariable("fundingId") int fundingId, @RequestParam(value = "page", defaultValue = "0") int page) {
        return orderService.getSellerFundingDetailOrderList(fundingId, page);
    }

    @PostMapping("/seller/month-amount-statistics")
    public List<GetSellerMonthAmountStatisticsResponseDto> getSellerMonthAmountStatistics(@RequestBody List<Integer> fundingIdList) {
        return orderService.getSellerMonthAmountStatistics(fundingIdList);
    }

    @GetMapping("/seller/funding/detail/statistics/{fundingId}")
    public List<GetSellerFundingDetailStatisticsResponseDto> getSellerFundingDetailStatistics(@PathVariable("fundingId") int fundingId) {
        return orderService.getSellerFundingDetailStatistics(fundingId);
    }

    @PostMapping("/seller/brand-statistics")
    public List<Integer> getSellerBrandStatistics(@RequestBody List<Integer> fundingIdList) {
        return orderService.getSellerBrandStatistics(fundingIdList);
    }

    @PostMapping("/seller/today-order/list")
    public List<GetSellerTodayOrderTopThreeIdAndMoneyResponseDto> getSellerTodayOrderTopThree(@RequestBody List<Integer> fundingIdList) {
        return orderService.getSellerTodayOrderTopThree(fundingIdList);
    }

}
