package com.coupon.controller;

import com.coupon.common.response.Response;
import com.coupon.common.util.CouponUtil;
import com.coupon.dto.CouponResponseDto;
import com.coupon.service.CouponRedisService;
import com.coupon.service.CouponService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.io.IOException;
import java.util.List;

import static com.coupon.common.response.ResponseCode.*;

@Slf4j
@RestController
@RequestMapping("/api/coupon")
@RequiredArgsConstructor
public class CouponController {

    private final CouponRedisService couponRedisService;
    private final CouponService couponService;

    @PostMapping("/issue")
    public ResponseEntity<?> issueCoupon(@RequestHeader("X-User-Id") int userId) throws IOException {
        couponRedisService.issueCoupon(userId, CouponUtil.generateTodayCode());
        return new ResponseEntity<>(Response.create(ISSUED_COUPON, null), ISSUED_COUPON.getHttpStatus());
    }

    @GetMapping("/count")
    public int countCoupon(@RequestHeader("X-User-Id") int userId) throws IOException {
        return couponService.countCoupon(userId);
    }

    @GetMapping
    public List<CouponResponseDto> getCoupons(@RequestHeader("X-User-Id") int userId) throws IOException {
        return couponService.getCoupons(userId);
    }

    @GetMapping("/info")
    public CouponResponseDto getCouponInfo(int couponId) throws IOException {
        return couponService.getCouponInfo(couponId);
    }

    @PostMapping("/use")
    public void useCoupon(int userId, int couponId, int fundingId) throws IOException {
        couponService.useCoupon(userId, couponId, fundingId);
    }
}
