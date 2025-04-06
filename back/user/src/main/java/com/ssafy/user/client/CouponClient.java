package com.ssafy.user.client;


import com.ssafy.user.dto.response.CouponResponseDto;
import org.springframework.cloud.openfeign.FeignClient;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestHeader;

import java.util.List;

@FeignClient(name = "coupon")
public interface CouponClient {

    @GetMapping("/api/coupon/")
    List<CouponResponseDto> getCouponList(@RequestHeader("X-User-Id") int userId);

    @PostMapping("/api/coupon/issue")
    void postCoupon(@RequestHeader("X-User-Id") int userId);
}
