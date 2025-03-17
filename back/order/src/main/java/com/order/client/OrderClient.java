package com.order.client;

import org.springframework.cloud.openfeign.FeignClient;

@FeignClient(name="order-service")
public class OrderClient {
}
