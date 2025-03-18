package com.ssafy.business.client;


import org.springframework.cloud.openfeign.FeignClient;

@FeignClient(name = "business")
public class BusinessClient {
}
