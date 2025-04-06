package com.coupon.controller;

import com.coupon.common.response.Response;
import com.coupon.common.util.CouponUtil;
import com.coupon.dto.CouponResponseDto;
import com.coupon.service.CouponRedisService;
import com.coupon.service.CouponService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.io.IOException;
import java.util.List;

import static com.coupon.common.response.ResponseCode.*;

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
    public ResponseEntity<?> countCoupon(@RequestHeader("X-User-Id") int userId) throws IOException {
        int count = couponService.countCoupon(userId);
        return new ResponseEntity<>(Response.create(GET_COUNT_COUPON, count), ISSUED_COUPON.getHttpStatus());
    }

    @GetMapping
    public ResponseEntity<?> getCoupons(@RequestHeader("X-User-Id") int userId) throws IOException {
        List<CouponResponseDto> coupons = couponService.getCoupons(userId);
        return new ResponseEntity<>(Response.create(GET_COUPONS, coupons), ISSUED_COUPON.getHttpStatus());
    }
}
