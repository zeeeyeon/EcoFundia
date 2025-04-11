package com.coupon.client;

import org.springframework.cloud.openfeign.FeignClient;

@FeignClient(name="coupon-service")
public class CouponClient {
}
