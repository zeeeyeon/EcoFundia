package com.seller.client;

import org.springframework.cloud.openfeign.FeignClient;

@FeignClient(name="seller-service")
public class sellerClient {
}
