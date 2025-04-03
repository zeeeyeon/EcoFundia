package com.coupon.controller;

import com.coupon.common.response.Response;
import com.coupon.service.CouponService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import static com.coupon.common.response.ResponseCode.ISSUED_COUPON;

@RestController
@RequestMapping("/api/coupon")
@RequiredArgsConstructor
public class CouponController {

    private final CouponService couponService;

    @PostMapping("/issue")
    public ResponseEntity<?> issueCoupon(@RequestHeader("X-User-Id") int userId) {
        couponService.issueCoupon(userId);
        return new ResponseEntity<>(Response.create(ISSUED_COUPON, null), ISSUED_COUPON.getHttpStatus());
    }

}
