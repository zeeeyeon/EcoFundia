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
    public OrderResponseDto createOrder(@RequestHeader("X-User-Id") int userId,
                                        @RequestParam(name = "fundingId") int fundingId,
                                        @RequestParam(name = "quantity") int quantity,
                                        @RequestParam(name = "totalPrice") int totalPrice){
        OrderResponseDto response = orderService.createOrder(userId, fundingId, quantity, totalPrice);
        return response;
    }

    @GetMapping("/my")
    public List<Order> getOrder(@RequestParam(name = "userId") int userId){
        return orderService.getOrder(userId);
    }
}
