package com.order.controller;

import com.order.dto.responseDto.OrderResponseDto;
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
    public OrderResponseDto createOrder(@RequestParam(name = "userId") int userId,
                                        @RequestParam(name = "fundingId") int fundingId,
                                        @RequestParam(name = "quantity") int quantity,
                                        @RequestParam(name = "totalPrice") int totalPrice,
                                        @RequestParam(name = "userKey") String userKey,
                                        @RequestParam(name = "userAccount") String userAccount
    ){
        OrderResponseDto response = orderService.createOrder(userId, fundingId, quantity, totalPrice, userKey, userAccount);
        return response;
    }

    @GetMapping("/my")
    public List<Order> getOrder(@RequestParam(name = "userId") int userId){
        return orderService.getOrder(userId);
    }
}
