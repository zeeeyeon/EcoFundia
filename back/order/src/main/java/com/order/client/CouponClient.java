package com.order.client;

import com.order.dto.coupon.CouponResponseDto;
import org.springframework.cloud.openfeign.FeignClient;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;

@FeignClient(name = "coupon" )
public interface CouponClient {
    @GetMapping("/api/coupon/info")
    CouponResponseDto getCouponInfo(@RequestParam("couponId") int couponId);

    @PostMapping("/api/coupon/use")
    void useCoupon(@RequestParam("userId") int userId, @RequestParam("couponId") int couponId);
}
